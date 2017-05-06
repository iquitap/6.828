
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  80004a:	e8 0d 01 00 00       	call   80015c <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800062:	e8 54 0a 00 00       	call   800abb <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 af 09 00 00       	call   800a69 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 14             	sub    $0x14,%esp
  8000c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cf:	40                   	inc    %eax
  8000d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d7:	75 19                	jne    8000f2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e0:	00 
  8000e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e4:	89 04 24             	mov    %eax,(%esp)
  8000e7:	e8 40 09 00 00       	call   800a2c <sys_cputs>
		b->idx = 0;
  8000ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f2:	ff 43 04             	incl   0x4(%ebx)
}
  8000f5:	83 c4 14             	add    $0x14,%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011f:	8b 45 08             	mov    0x8(%ebp),%eax
  800122:	89 44 24 08          	mov    %eax,0x8(%esp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 bc 00 80 00 	movl   $0x8000bc,(%esp)
  800137:	e8 82 01 00 00       	call   8002be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 d8 08 00 00       	call   800a2c <sys_cputs>

	return b.cnt;
}
  800154:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800162:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	8b 45 08             	mov    0x8(%ebp),%eax
  80016c:	89 04 24             	mov    %eax,(%esp)
  80016f:	e8 87 ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    
	...

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 3c             	sub    $0x3c,%esp
  800181:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800184:	89 d7                	mov    %edx,%edi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80018c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800192:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800195:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	85 c0                	test   %eax,%eax
  80019a:	75 08                	jne    8001a4 <printnum+0x2c>
  80019c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 57                	ja     8001fb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001a8:	4b                   	dec    %ebx
  8001a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c3:	00 
  8001c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d1:	e8 92 0b 00 00       	call   800d68 <__udivdi3>
  8001d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e5:	89 fa                	mov    %edi,%edx
  8001e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ea:	e8 89 ff ff ff       	call   800178 <printnum>
  8001ef:	eb 0f                	jmp    800200 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f5:	89 34 24             	mov    %esi,(%esp)
  8001f8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fb:	4b                   	dec    %ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7f f1                	jg     8001f1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800200:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800204:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800216:	00 
  800217:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	e8 5f 0c 00 00       	call   800e88 <__umoddi3>
  800229:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022d:	0f be 80 f1 0f 80 00 	movsbl 0x800ff1(%eax),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80023a:	83 c4 3c             	add    $0x3c,%esp
  80023d:	5b                   	pop    %ebx
  80023e:	5e                   	pop    %esi
  80023f:	5f                   	pop    %edi
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    

00800242 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800245:	83 fa 01             	cmp    $0x1,%edx
  800248:	7e 0e                	jle    800258 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024a:	8b 10                	mov    (%eax),%edx
  80024c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024f:	89 08                	mov    %ecx,(%eax)
  800251:	8b 02                	mov    (%edx),%eax
  800253:	8b 52 04             	mov    0x4(%edx),%edx
  800256:	eb 22                	jmp    80027a <getuint+0x38>
	else if (lflag)
  800258:	85 d2                	test   %edx,%edx
  80025a:	74 10                	je     80026c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
  80026a:	eb 0e                	jmp    80027a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800282:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800285:	8b 10                	mov    (%eax),%edx
  800287:	3b 50 04             	cmp    0x4(%eax),%edx
  80028a:	73 08                	jae    800294 <sprintputch+0x18>
		*b->buf++ = ch;
  80028c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028f:	88 0a                	mov    %cl,(%edx)
  800291:	42                   	inc    %edx
  800292:	89 10                	mov    %edx,(%eax)
}
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80029c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 02 00 00 00       	call   8002be <vprintfmt>
	va_end(ap);
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 4c             	sub    $0x4c,%esp
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ca:	8b 75 10             	mov    0x10(%ebp),%esi
  8002cd:	eb 12                	jmp    8002e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	0f 84 6b 03 00 00    	je     800642 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e1:	0f b6 06             	movzbl (%esi),%eax
  8002e4:	46                   	inc    %esi
  8002e5:	83 f8 25             	cmp    $0x25,%eax
  8002e8:	75 e5                	jne    8002cf <vprintfmt+0x11>
  8002ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800301:	b9 00 00 00 00       	mov    $0x0,%ecx
  800306:	eb 26                	jmp    80032e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80030f:	eb 1d                	jmp    80032e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800314:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800318:	eb 14                	jmp    80032e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80031d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800324:	eb 08                	jmp    80032e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800326:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800329:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	0f b6 06             	movzbl (%esi),%eax
  800331:	8d 56 01             	lea    0x1(%esi),%edx
  800334:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800337:	8a 16                	mov    (%esi),%dl
  800339:	83 ea 23             	sub    $0x23,%edx
  80033c:	80 fa 55             	cmp    $0x55,%dl
  80033f:	0f 87 e1 02 00 00    	ja     800626 <vprintfmt+0x368>
  800345:	0f b6 d2             	movzbl %dl,%edx
  800348:	ff 24 95 c0 10 80 00 	jmp    *0x8010c0(,%edx,4)
  80034f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800352:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800357:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80035a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80035e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800361:	8d 50 d0             	lea    -0x30(%eax),%edx
  800364:	83 fa 09             	cmp    $0x9,%edx
  800367:	77 2a                	ja     800393 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800369:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036a:	eb eb                	jmp    800357 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	8d 50 04             	lea    0x4(%eax),%edx
  800372:	89 55 14             	mov    %edx,0x14(%ebp)
  800375:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 17                	jmp    800393 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80037c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800380:	78 98                	js     80031a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800385:	eb a7                	jmp    80032e <vprintfmt+0x70>
  800387:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800391:	eb 9b                	jmp    80032e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800393:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800397:	79 95                	jns    80032e <vprintfmt+0x70>
  800399:	eb 8b                	jmp    800326 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039f:	eb 8d                	jmp    80032e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 50 04             	lea    0x4(%eax),%edx
  8003a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b9:	e9 23 ff ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 50 04             	lea    0x4(%eax),%edx
  8003c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c7:	8b 00                	mov    (%eax),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	79 02                	jns    8003cf <vprintfmt+0x111>
  8003cd:	f7 d8                	neg    %eax
  8003cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 09             	cmp    $0x9,%eax
  8003d4:	7f 0b                	jg     8003e1 <vprintfmt+0x123>
  8003d6:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	75 23                	jne    800404 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e5:	c7 44 24 08 09 10 80 	movl   $0x801009,0x8(%esp)
  8003ec:	00 
  8003ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 9a fe ff ff       	call   800296 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 dd fe ff ff       	jmp    8002e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800408:	c7 44 24 08 12 10 80 	movl   $0x801012,0x8(%esp)
  80040f:	00 
  800410:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800414:	8b 55 08             	mov    0x8(%ebp),%edx
  800417:	89 14 24             	mov    %edx,(%esp)
  80041a:	e8 77 fe ff ff       	call   800296 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800422:	e9 ba fe ff ff       	jmp    8002e1 <vprintfmt+0x23>
  800427:	89 f9                	mov    %edi,%ecx
  800429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	8b 30                	mov    (%eax),%esi
  80043a:	85 f6                	test   %esi,%esi
  80043c:	75 05                	jne    800443 <vprintfmt+0x185>
				p = "(null)";
  80043e:	be 02 10 80 00       	mov    $0x801002,%esi
			if (width > 0 && padc != '-')
  800443:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800447:	0f 8e 84 00 00 00    	jle    8004d1 <vprintfmt+0x213>
  80044d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800451:	74 7e                	je     8004d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800457:	89 34 24             	mov    %esi,(%esp)
  80045a:	e8 8b 02 00 00       	call   8006ea <strnlen>
  80045f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800462:	29 c2                	sub    %eax,%edx
  800464:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800467:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80046b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80046e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800471:	89 de                	mov    %ebx,%esi
  800473:	89 d3                	mov    %edx,%ebx
  800475:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	eb 0b                	jmp    800484 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800479:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047d:	89 3c 24             	mov    %edi,(%esp)
  800480:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	4b                   	dec    %ebx
  800484:	85 db                	test   %ebx,%ebx
  800486:	7f f1                	jg     800479 <vprintfmt+0x1bb>
  800488:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80048b:	89 f3                	mov    %esi,%ebx
  80048d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800490:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	79 05                	jns    80049c <vprintfmt+0x1de>
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	29 c2                	sub    %eax,%edx
  8004a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a4:	eb 2b                	jmp    8004d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004aa:	74 18                	je     8004c4 <vprintfmt+0x206>
  8004ac:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004af:	83 fa 5e             	cmp    $0x5e,%edx
  8004b2:	76 10                	jbe    8004c4 <vprintfmt+0x206>
					putch('?', putdat);
  8004b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
  8004c2:	eb 0a                	jmp    8004ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d1:	0f be 06             	movsbl (%esi),%eax
  8004d4:	46                   	inc    %esi
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 21                	je     8004fa <vprintfmt+0x23c>
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	78 c9                	js     8004a6 <vprintfmt+0x1e8>
  8004dd:	4f                   	dec    %edi
  8004de:	79 c6                	jns    8004a6 <vprintfmt+0x1e8>
  8004e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e3:	89 de                	mov    %ebx,%esi
  8004e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f7:	4b                   	dec    %ebx
  8004f8:	eb 08                	jmp    800502 <vprintfmt+0x244>
  8004fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004fd:	89 de                	mov    %ebx,%esi
  8004ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800502:	85 db                	test   %ebx,%ebx
  800504:	7f e4                	jg     8004ea <vprintfmt+0x22c>
  800506:	89 7d 08             	mov    %edi,0x8(%ebp)
  800509:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050e:	e9 ce fd ff ff       	jmp    8002e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800513:	83 f9 01             	cmp    $0x1,%ecx
  800516:	7e 10                	jle    800528 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 08             	lea    0x8(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 30                	mov    (%eax),%esi
  800523:	8b 78 04             	mov    0x4(%eax),%edi
  800526:	eb 26                	jmp    80054e <vprintfmt+0x290>
	else if (lflag)
  800528:	85 c9                	test   %ecx,%ecx
  80052a:	74 12                	je     80053e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	89 f7                	mov    %esi,%edi
  800539:	c1 ff 1f             	sar    $0x1f,%edi
  80053c:	eb 10                	jmp    80054e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 30                	mov    (%eax),%esi
  800549:	89 f7                	mov    %esi,%edi
  80054b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80054e:	85 ff                	test   %edi,%edi
  800550:	78 0a                	js     80055c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 8c 00 00 00       	jmp    8005e8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800567:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80056a:	f7 de                	neg    %esi
  80056c:	83 d7 00             	adc    $0x0,%edi
  80056f:	f7 df                	neg    %edi
			}
			base = 10;
  800571:	b8 0a 00 00 00       	mov    $0xa,%eax
  800576:	eb 70                	jmp    8005e8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800578:	89 ca                	mov    %ecx,%edx
  80057a:	8d 45 14             	lea    0x14(%ebp),%eax
  80057d:	e8 c0 fc ff ff       	call   800242 <getuint>
  800582:	89 c6                	mov    %eax,%esi
  800584:	89 d7                	mov    %edx,%edi
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80058b:	eb 5b                	jmp    8005e8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  80058d:	89 ca                	mov    %ecx,%edx
  80058f:	8d 45 14             	lea    0x14(%ebp),%eax
  800592:	e8 ab fc ff ff       	call   800242 <getuint>
  800597:	89 c6                	mov    %eax,%esi
  800599:	89 d7                	mov    %edx,%edi
                        base = 8;
  80059b:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8005a0:	eb 46                	jmp    8005e8 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8005a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c7:	8b 30                	mov    (%eax),%esi
  8005c9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005d3:	eb 13                	jmp    8005e8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d5:	89 ca                	mov    %ecx,%edx
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 63 fc ff ff       	call   800242 <getuint>
  8005df:	89 c6                	mov    %eax,%esi
  8005e1:	89 d7                	mov    %edx,%edi
			base = 16;
  8005e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fb:	89 34 24             	mov    %esi,(%esp)
  8005fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800602:	89 da                	mov    %ebx,%edx
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	e8 6c fb ff ff       	call   800178 <printnum>
			break;
  80060c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060f:	e9 cd fc ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800621:	e9 bb fc ff ff       	jmp    8002e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800626:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800631:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800634:	eb 01                	jmp    800637 <vprintfmt+0x379>
  800636:	4e                   	dec    %esi
  800637:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80063b:	75 f9                	jne    800636 <vprintfmt+0x378>
  80063d:	e9 9f fc ff ff       	jmp    8002e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800642:	83 c4 4c             	add    $0x4c,%esp
  800645:	5b                   	pop    %ebx
  800646:	5e                   	pop    %esi
  800647:	5f                   	pop    %edi
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	83 ec 28             	sub    $0x28,%esp
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800656:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800659:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800667:	85 c0                	test   %eax,%eax
  800669:	74 30                	je     80069b <vsnprintf+0x51>
  80066b:	85 d2                	test   %edx,%edx
  80066d:	7e 33                	jle    8006a2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800676:	8b 45 10             	mov    0x10(%ebp),%eax
  800679:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800680:	89 44 24 04          	mov    %eax,0x4(%esp)
  800684:	c7 04 24 7c 02 80 00 	movl   $0x80027c,(%esp)
  80068b:	e8 2e fc ff ff       	call   8002be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	eb 0c                	jmp    8006a7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a0:	eb 05                	jmp    8006a7 <vsnprintf+0x5d>
  8006a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	e8 7b ff ff ff       	call   80064a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    
  8006d1:	00 00                	add    %al,(%eax)
	...

008006d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	eb 01                	jmp    8006e2 <strlen+0xe>
		n++;
  8006e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e6:	75 f9                	jne    8006e1 <strlen+0xd>
		n++;
	return n;
}
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	eb 01                	jmp    8006fb <strnlen+0x11>
		n++;
  8006fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	39 d0                	cmp    %edx,%eax
  8006fd:	74 06                	je     800705 <strnlen+0x1b>
  8006ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800703:	75 f5                	jne    8006fa <strnlen+0x10>
		n++;
	return n;
}
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800711:	ba 00 00 00 00       	mov    $0x0,%edx
  800716:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800719:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80071c:	42                   	inc    %edx
  80071d:	84 c9                	test   %cl,%cl
  80071f:	75 f5                	jne    800716 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800721:	5b                   	pop    %ebx
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	53                   	push   %ebx
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072e:	89 1c 24             	mov    %ebx,(%esp)
  800731:	e8 9e ff ff ff       	call   8006d4 <strlen>
	strcpy(dst + len, src);
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
  800739:	89 54 24 04          	mov    %edx,0x4(%esp)
  80073d:	01 d8                	add    %ebx,%eax
  80073f:	89 04 24             	mov    %eax,(%esp)
  800742:	e8 c0 ff ff ff       	call   800707 <strcpy>
	return dst;
}
  800747:	89 d8                	mov    %ebx,%eax
  800749:	83 c4 08             	add    $0x8,%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	56                   	push   %esi
  800753:	53                   	push   %ebx
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	eb 0c                	jmp    800770 <strncpy+0x21>
		*dst++ = *src;
  800764:	8a 1a                	mov    (%edx),%bl
  800766:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800769:	80 3a 01             	cmpb   $0x1,(%edx)
  80076c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076f:	41                   	inc    %ecx
  800770:	39 f1                	cmp    %esi,%ecx
  800772:	75 f0                	jne    800764 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800786:	85 d2                	test   %edx,%edx
  800788:	75 0a                	jne    800794 <strlcpy+0x1c>
  80078a:	89 f0                	mov    %esi,%eax
  80078c:	eb 1a                	jmp    8007a8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078e:	88 18                	mov    %bl,(%eax)
  800790:	40                   	inc    %eax
  800791:	41                   	inc    %ecx
  800792:	eb 02                	jmp    800796 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800794:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800796:	4a                   	dec    %edx
  800797:	74 0a                	je     8007a3 <strlcpy+0x2b>
  800799:	8a 19                	mov    (%ecx),%bl
  80079b:	84 db                	test   %bl,%bl
  80079d:	75 ef                	jne    80078e <strlcpy+0x16>
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	eb 02                	jmp    8007a5 <strlcpy+0x2d>
  8007a3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007a5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007a8:	29 f0                	sub    %esi,%eax
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b7:	eb 02                	jmp    8007bb <strcmp+0xd>
		p++, q++;
  8007b9:	41                   	inc    %ecx
  8007ba:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bb:	8a 01                	mov    (%ecx),%al
  8007bd:	84 c0                	test   %al,%al
  8007bf:	74 04                	je     8007c5 <strcmp+0x17>
  8007c1:	3a 02                	cmp    (%edx),%al
  8007c3:	74 f4                	je     8007b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c5:	0f b6 c0             	movzbl %al,%eax
  8007c8:	0f b6 12             	movzbl (%edx),%edx
  8007cb:	29 d0                	sub    %edx,%eax
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007dc:	eb 03                	jmp    8007e1 <strncmp+0x12>
		n--, p++, q++;
  8007de:	4a                   	dec    %edx
  8007df:	40                   	inc    %eax
  8007e0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	74 14                	je     8007f9 <strncmp+0x2a>
  8007e5:	8a 18                	mov    (%eax),%bl
  8007e7:	84 db                	test   %bl,%bl
  8007e9:	74 04                	je     8007ef <strncmp+0x20>
  8007eb:	3a 19                	cmp    (%ecx),%bl
  8007ed:	74 ef                	je     8007de <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ef:	0f b6 00             	movzbl (%eax),%eax
  8007f2:	0f b6 11             	movzbl (%ecx),%edx
  8007f5:	29 d0                	sub    %edx,%eax
  8007f7:	eb 05                	jmp    8007fe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80080a:	eb 05                	jmp    800811 <strchr+0x10>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0c                	je     80081c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	40                   	inc    %eax
  800811:	8a 10                	mov    (%eax),%dl
  800813:	84 d2                	test   %dl,%dl
  800815:	75 f5                	jne    80080c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800827:	eb 05                	jmp    80082e <strfind+0x10>
		if (*s == c)
  800829:	38 ca                	cmp    %cl,%dl
  80082b:	74 07                	je     800834 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80082d:	40                   	inc    %eax
  80082e:	8a 10                	mov    (%eax),%dl
  800830:	84 d2                	test   %dl,%dl
  800832:	75 f5                	jne    800829 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	57                   	push   %edi
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800842:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 30                	je     800879 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800849:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084f:	75 25                	jne    800876 <memset+0x40>
  800851:	f6 c1 03             	test   $0x3,%cl
  800854:	75 20                	jne    800876 <memset+0x40>
		c &= 0xFF;
  800856:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800859:	89 d3                	mov    %edx,%ebx
  80085b:	c1 e3 08             	shl    $0x8,%ebx
  80085e:	89 d6                	mov    %edx,%esi
  800860:	c1 e6 18             	shl    $0x18,%esi
  800863:	89 d0                	mov    %edx,%eax
  800865:	c1 e0 10             	shl    $0x10,%eax
  800868:	09 f0                	or     %esi,%eax
  80086a:	09 d0                	or     %edx,%eax
  80086c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80086e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800871:	fc                   	cld    
  800872:	f3 ab                	rep stos %eax,%es:(%edi)
  800874:	eb 03                	jmp    800879 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800876:	fc                   	cld    
  800877:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800879:	89 f8                	mov    %edi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	57                   	push   %edi
  800884:	56                   	push   %esi
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088e:	39 c6                	cmp    %eax,%esi
  800890:	73 34                	jae    8008c6 <memmove+0x46>
  800892:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800895:	39 d0                	cmp    %edx,%eax
  800897:	73 2d                	jae    8008c6 <memmove+0x46>
		s += n;
		d += n;
  800899:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089c:	f6 c2 03             	test   $0x3,%dl
  80089f:	75 1b                	jne    8008bc <memmove+0x3c>
  8008a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a7:	75 13                	jne    8008bc <memmove+0x3c>
  8008a9:	f6 c1 03             	test   $0x3,%cl
  8008ac:	75 0e                	jne    8008bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ae:	83 ef 04             	sub    $0x4,%edi
  8008b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008b7:	fd                   	std    
  8008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ba:	eb 07                	jmp    8008c3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008bc:	4f                   	dec    %edi
  8008bd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c0:	fd                   	std    
  8008c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c3:	fc                   	cld    
  8008c4:	eb 20                	jmp    8008e6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cc:	75 13                	jne    8008e1 <memmove+0x61>
  8008ce:	a8 03                	test   $0x3,%al
  8008d0:	75 0f                	jne    8008e1 <memmove+0x61>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0a                	jne    8008e1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	fc                   	cld    
  8008dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008df:	eb 05                	jmp    8008e6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e1:	89 c7                	mov    %eax,%edi
  8008e3:	fc                   	cld    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	89 04 24             	mov    %eax,(%esp)
  800904:	e8 77 ff ff ff       	call   800880 <memmove>
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 7d 08             	mov    0x8(%ebp),%edi
  800914:	8b 75 0c             	mov    0xc(%ebp),%esi
  800917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091a:	ba 00 00 00 00       	mov    $0x0,%edx
  80091f:	eb 16                	jmp    800937 <memcmp+0x2c>
		if (*s1 != *s2)
  800921:	8a 04 17             	mov    (%edi,%edx,1),%al
  800924:	42                   	inc    %edx
  800925:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800929:	38 c8                	cmp    %cl,%al
  80092b:	74 0a                	je     800937 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	0f b6 c9             	movzbl %cl,%ecx
  800933:	29 c8                	sub    %ecx,%eax
  800935:	eb 09                	jmp    800940 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800937:	39 da                	cmp    %ebx,%edx
  800939:	75 e6                	jne    800921 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80094e:	89 c2                	mov    %eax,%edx
  800950:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800953:	eb 05                	jmp    80095a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800955:	38 08                	cmp    %cl,(%eax)
  800957:	74 05                	je     80095e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800959:	40                   	inc    %eax
  80095a:	39 d0                	cmp    %edx,%eax
  80095c:	72 f7                	jb     800955 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 55 08             	mov    0x8(%ebp),%edx
  800969:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096c:	eb 01                	jmp    80096f <strtol+0xf>
		s++;
  80096e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096f:	8a 02                	mov    (%edx),%al
  800971:	3c 20                	cmp    $0x20,%al
  800973:	74 f9                	je     80096e <strtol+0xe>
  800975:	3c 09                	cmp    $0x9,%al
  800977:	74 f5                	je     80096e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800979:	3c 2b                	cmp    $0x2b,%al
  80097b:	75 08                	jne    800985 <strtol+0x25>
		s++;
  80097d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80097e:	bf 00 00 00 00       	mov    $0x0,%edi
  800983:	eb 13                	jmp    800998 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800985:	3c 2d                	cmp    $0x2d,%al
  800987:	75 0a                	jne    800993 <strtol+0x33>
		s++, neg = 1;
  800989:	8d 52 01             	lea    0x1(%edx),%edx
  80098c:	bf 01 00 00 00       	mov    $0x1,%edi
  800991:	eb 05                	jmp    800998 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800993:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800998:	85 db                	test   %ebx,%ebx
  80099a:	74 05                	je     8009a1 <strtol+0x41>
  80099c:	83 fb 10             	cmp    $0x10,%ebx
  80099f:	75 28                	jne    8009c9 <strtol+0x69>
  8009a1:	8a 02                	mov    (%edx),%al
  8009a3:	3c 30                	cmp    $0x30,%al
  8009a5:	75 10                	jne    8009b7 <strtol+0x57>
  8009a7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009ab:	75 0a                	jne    8009b7 <strtol+0x57>
		s += 2, base = 16;
  8009ad:	83 c2 02             	add    $0x2,%edx
  8009b0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b5:	eb 12                	jmp    8009c9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	75 0e                	jne    8009c9 <strtol+0x69>
  8009bb:	3c 30                	cmp    $0x30,%al
  8009bd:	75 05                	jne    8009c4 <strtol+0x64>
		s++, base = 8;
  8009bf:	42                   	inc    %edx
  8009c0:	b3 08                	mov    $0x8,%bl
  8009c2:	eb 05                	jmp    8009c9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009c4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ce:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d0:	8a 0a                	mov    (%edx),%cl
  8009d2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009d5:	80 fb 09             	cmp    $0x9,%bl
  8009d8:	77 08                	ja     8009e2 <strtol+0x82>
			dig = *s - '0';
  8009da:	0f be c9             	movsbl %cl,%ecx
  8009dd:	83 e9 30             	sub    $0x30,%ecx
  8009e0:	eb 1e                	jmp    800a00 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009e2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009e5:	80 fb 19             	cmp    $0x19,%bl
  8009e8:	77 08                	ja     8009f2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009ea:	0f be c9             	movsbl %cl,%ecx
  8009ed:	83 e9 57             	sub    $0x57,%ecx
  8009f0:	eb 0e                	jmp    800a00 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009f2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 12                	ja     800a0c <strtol+0xac>
			dig = *s - 'A' + 10;
  8009fa:	0f be c9             	movsbl %cl,%ecx
  8009fd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a00:	39 f1                	cmp    %esi,%ecx
  800a02:	7d 0c                	jge    800a10 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a04:	42                   	inc    %edx
  800a05:	0f af c6             	imul   %esi,%eax
  800a08:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a0a:	eb c4                	jmp    8009d0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a0c:	89 c1                	mov    %eax,%ecx
  800a0e:	eb 02                	jmp    800a12 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a10:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a16:	74 05                	je     800a1d <strtol+0xbd>
		*endptr = (char *) s;
  800a18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a1d:	85 ff                	test   %edi,%edi
  800a1f:	74 04                	je     800a25 <strtol+0xc5>
  800a21:	89 c8                	mov    %ecx,%eax
  800a23:	f7 d8                	neg    %eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    
	...

00800a2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	89 c6                	mov    %eax,%esi
  800a43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5a:	89 d1                	mov    %edx,%ecx
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	89 d7                	mov    %edx,%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a77:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	89 cb                	mov    %ecx,%ebx
  800a81:	89 cf                	mov    %ecx,%edi
  800a83:	89 ce                	mov    %ecx,%esi
  800a85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	7e 28                	jle    800ab3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a96:	00 
  800a97:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800a9e:	00 
  800a9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aa6:	00 
  800aa7:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800aae:	e8 5d 02 00 00       	call   800d10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab3:	83 c4 2c             	add    $0x2c,%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	b8 02 00 00 00       	mov    $0x2,%eax
  800acb:	89 d1                	mov    %edx,%ecx
  800acd:	89 d3                	mov    %edx,%ebx
  800acf:	89 d7                	mov    %edx,%edi
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_yield>:

void
sys_yield(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	be 00 00 00 00       	mov    $0x0,%esi
  800b07:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 f7                	mov    %esi,%edi
  800b17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 28                	jle    800b45 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b21:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b28:	00 
  800b29:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800b30:	00 
  800b31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b38:	00 
  800b39:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800b40:	e8 cb 01 00 00       	call   800d10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b45:	83 c4 2c             	add    $0x2c,%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7e 28                	jle    800b98 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b74:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b7b:	00 
  800b7c:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800b83:	00 
  800b84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8b:	00 
  800b8c:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800b93:	e8 78 01 00 00       	call   800d10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b98:	83 c4 2c             	add    $0x2c,%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 28                	jle    800beb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bce:	00 
  800bcf:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bde:	00 
  800bdf:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800be6:	e8 25 01 00 00       	call   800d10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800beb:	83 c4 2c             	add    $0x2c,%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	b8 08 00 00 00       	mov    $0x8,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 28                	jle    800c3e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c21:	00 
  800c22:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800c29:	00 
  800c2a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c31:	00 
  800c32:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800c39:	e8 d2 00 00 00       	call   800d10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3e:	83 c4 2c             	add    $0x2c,%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 09 00 00 00       	mov    $0x9,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 28                	jle    800c91 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c74:	00 
  800c75:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c84:	00 
  800c85:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800c8c:	e8 7f 00 00 00       	call   800d10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c91:	83 c4 2c             	add    $0x2c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 cb                	mov    %ecx,%ebx
  800cd4:	89 cf                	mov    %ecx,%edi
  800cd6:	89 ce                	mov    %ecx,%esi
  800cd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 28                	jle    800d06 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ce9:	00 
  800cea:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800cf1:	00 
  800cf2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf9:	00 
  800cfa:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800d01:	e8 0a 00 00 00       	call   800d10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d06:	83 c4 2c             	add    $0x2c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
	...

00800d10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d18:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d1b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d21:	e8 95 fd ff ff       	call   800abb <sys_getenvid>
  800d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d29:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3c:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800d43:	e8 14 f4 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d48:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4f:	89 04 24             	mov    %eax,(%esp)
  800d52:	e8 a4 f3 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800d57:	c7 04 24 98 12 80 00 	movl   $0x801298,(%esp)
  800d5e:	e8 f9 f3 ff ff       	call   80015c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d63:	cc                   	int3   
  800d64:	eb fd                	jmp    800d63 <_panic+0x53>
	...

00800d68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d68:	55                   	push   %ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	83 ec 10             	sub    $0x10,%esp
  800d6e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d72:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d7e:	89 cd                	mov    %ecx,%ebp
  800d80:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	75 2c                	jne    800db4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d88:	39 f9                	cmp    %edi,%ecx
  800d8a:	77 68                	ja     800df4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d8c:	85 c9                	test   %ecx,%ecx
  800d8e:	75 0b                	jne    800d9b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d90:	b8 01 00 00 00       	mov    $0x1,%eax
  800d95:	31 d2                	xor    %edx,%edx
  800d97:	f7 f1                	div    %ecx
  800d99:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	89 f8                	mov    %edi,%eax
  800d9f:	f7 f1                	div    %ecx
  800da1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da3:	89 f0                	mov    %esi,%eax
  800da5:	f7 f1                	div    %ecx
  800da7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800db4:	39 f8                	cmp    %edi,%eax
  800db6:	77 2c                	ja     800de4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800db8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dbb:	83 f6 1f             	xor    $0x1f,%esi
  800dbe:	75 4c                	jne    800e0c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc7:	72 0a                	jb     800dd3 <__udivdi3+0x6b>
  800dc9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dcd:	0f 87 ad 00 00 00    	ja     800e80 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd8:	89 f0                	mov    %esi,%eax
  800dda:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    
  800de3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de8:	89 f0                	mov    %esi,%eax
  800dea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
  800df3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df4:	89 fa                	mov    %edi,%edx
  800df6:	89 f0                	mov    %esi,%eax
  800df8:	f7 f1                	div    %ecx
  800dfa:	89 c6                	mov    %eax,%esi
  800dfc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
  800e09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e0c:	89 f1                	mov    %esi,%ecx
  800e0e:	d3 e0                	shl    %cl,%eax
  800e10:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e14:	b8 20 00 00 00       	mov    $0x20,%eax
  800e19:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e1b:	89 ea                	mov    %ebp,%edx
  800e1d:	88 c1                	mov    %al,%cl
  800e1f:	d3 ea                	shr    %cl,%edx
  800e21:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e25:	09 ca                	or     %ecx,%edx
  800e27:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e2b:	89 f1                	mov    %esi,%ecx
  800e2d:	d3 e5                	shl    %cl,%ebp
  800e2f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e33:	89 fd                	mov    %edi,%ebp
  800e35:	88 c1                	mov    %al,%cl
  800e37:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e39:	89 fa                	mov    %edi,%edx
  800e3b:	89 f1                	mov    %esi,%ecx
  800e3d:	d3 e2                	shl    %cl,%edx
  800e3f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e43:	88 c1                	mov    %al,%cl
  800e45:	d3 ef                	shr    %cl,%edi
  800e47:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e49:	89 f8                	mov    %edi,%eax
  800e4b:	89 ea                	mov    %ebp,%edx
  800e4d:	f7 74 24 08          	divl   0x8(%esp)
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e55:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e59:	39 d1                	cmp    %edx,%ecx
  800e5b:	72 17                	jb     800e74 <__udivdi3+0x10c>
  800e5d:	74 09                	je     800e68 <__udivdi3+0x100>
  800e5f:	89 fe                	mov    %edi,%esi
  800e61:	31 ff                	xor    %edi,%edi
  800e63:	e9 41 ff ff ff       	jmp    800da9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e68:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e6c:	89 f1                	mov    %esi,%ecx
  800e6e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e70:	39 c2                	cmp    %eax,%edx
  800e72:	73 eb                	jae    800e5f <__udivdi3+0xf7>
		{
		  q0--;
  800e74:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e77:	31 ff                	xor    %edi,%edi
  800e79:	e9 2b ff ff ff       	jmp    800da9 <__udivdi3+0x41>
  800e7e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e80:	31 f6                	xor    %esi,%esi
  800e82:	e9 22 ff ff ff       	jmp    800da9 <__udivdi3+0x41>
	...

00800e88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e88:	55                   	push   %ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	83 ec 20             	sub    $0x20,%esp
  800e8e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e92:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e96:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e9a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ea2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ea6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ea8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eaa:	85 ed                	test   %ebp,%ebp
  800eac:	75 16                	jne    800ec4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800eae:	39 f1                	cmp    %esi,%ecx
  800eb0:	0f 86 a6 00 00 00    	jbe    800f5c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800eb8:	89 d0                	mov    %edx,%eax
  800eba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ebc:	83 c4 20             	add    $0x20,%esp
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ec4:	39 f5                	cmp    %esi,%ebp
  800ec6:	0f 87 ac 00 00 00    	ja     800f78 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ecc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ecf:	83 f0 1f             	xor    $0x1f,%eax
  800ed2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed6:	0f 84 a8 00 00 00    	je     800f84 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800edc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ee0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ee2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800eeb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eef:	89 f9                	mov    %edi,%ecx
  800ef1:	d3 e8                	shr    %cl,%eax
  800ef3:	09 e8                	or     %ebp,%eax
  800ef5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800ef9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800efd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f01:	d3 e0                	shl    %cl,%eax
  800f03:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f07:	89 f2                	mov    %esi,%edx
  800f09:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f0b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f0f:	d3 e0                	shl    %cl,%eax
  800f11:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f15:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f19:	89 f9                	mov    %edi,%ecx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f1f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f21:	89 f2                	mov    %esi,%edx
  800f23:	f7 74 24 18          	divl   0x18(%esp)
  800f27:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f29:	f7 64 24 0c          	mull   0xc(%esp)
  800f2d:	89 c5                	mov    %eax,%ebp
  800f2f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f31:	39 d6                	cmp    %edx,%esi
  800f33:	72 67                	jb     800f9c <__umoddi3+0x114>
  800f35:	74 75                	je     800fac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f37:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f3b:	29 e8                	sub    %ebp,%eax
  800f3d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f3f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f43:	d3 e8                	shr    %cl,%eax
  800f45:	89 f2                	mov    %esi,%edx
  800f47:	89 f9                	mov    %edi,%ecx
  800f49:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f4b:	09 d0                	or     %edx,%eax
  800f4d:	89 f2                	mov    %esi,%edx
  800f4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f53:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f5c:	85 c9                	test   %ecx,%ecx
  800f5e:	75 0b                	jne    800f6b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f60:	b8 01 00 00 00       	mov    $0x1,%eax
  800f65:	31 d2                	xor    %edx,%edx
  800f67:	f7 f1                	div    %ecx
  800f69:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f6b:	89 f0                	mov    %esi,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f71:	89 f8                	mov    %edi,%eax
  800f73:	e9 3e ff ff ff       	jmp    800eb6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f78:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    
  800f81:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f84:	39 f5                	cmp    %esi,%ebp
  800f86:	72 04                	jb     800f8c <__umoddi3+0x104>
  800f88:	39 f9                	cmp    %edi,%ecx
  800f8a:	77 06                	ja     800f92 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f8c:	89 f2                	mov    %esi,%edx
  800f8e:	29 cf                	sub    %ecx,%edi
  800f90:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f92:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f94:	83 c4 20             	add    $0x20,%esp
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    
  800f9b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f9c:	89 d1                	mov    %edx,%ecx
  800f9e:	89 c5                	mov    %eax,%ebp
  800fa0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fa4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fa8:	eb 8d                	jmp    800f37 <__umoddi3+0xaf>
  800faa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fb0:	72 ea                	jb     800f9c <__umoddi3+0x114>
  800fb2:	89 f1                	mov    %esi,%ecx
  800fb4:	eb 81                	jmp    800f37 <__umoddi3+0xaf>
