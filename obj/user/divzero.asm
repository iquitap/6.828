
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  80005c:	e8 0b 01 00 00       	call   80016c <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 10             	sub    $0x10,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800072:	e8 54 0a 00 00       	call   800acb <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 08 20 80 00       	mov    %eax,0x802008

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 07                	jle    80009d <libmain+0x39>
		binaryname = argv[0];
  800096:	8b 03                	mov    (%ebx),%eax
  800098:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	89 34 24             	mov    %esi,(%esp)
  8000a4:	e8 8b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a9:	e8 0a 00 00 00       	call   8000b8 <exit>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    
  8000b5:	00 00                	add    %al,(%eax)
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 af 09 00 00       	call   800a79 <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 14             	sub    $0x14,%esp
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d6:	8b 03                	mov    (%ebx),%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000df:	40                   	inc    %eax
  8000e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e7:	75 19                	jne    800102 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f0:	00 
  8000f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f4:	89 04 24             	mov    %eax,(%esp)
  8000f7:	e8 40 09 00 00       	call   800a3c <sys_cputs>
		b->idx = 0;
  8000fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800102:	ff 43 04             	incl   0x4(%ebx)
}
  800105:	83 c4 14             	add    $0x14,%esp
  800108:	5b                   	pop    %ebx
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800114:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011b:	00 00 00 
	b.cnt = 0;
  80011e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800125:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012f:	8b 45 08             	mov    0x8(%ebp),%eax
  800132:	89 44 24 08          	mov    %eax,0x8(%esp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 cc 00 80 00 	movl   $0x8000cc,(%esp)
  800147:	e8 82 01 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800152:	89 44 24 04          	mov    %eax,0x4(%esp)
  800156:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 d8 08 00 00       	call   800a3c <sys_cputs>

	return b.cnt;
}
  800164:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800172:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	e8 87 ff ff ff       	call   80010b <vcprintf>
	va_end(ap);

	return cnt;
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    
	...

00800188 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 3c             	sub    $0x3c,%esp
  800191:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800194:	89 d7                	mov    %edx,%edi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	75 08                	jne    8001b4 <printnum+0x2c>
  8001ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b2:	77 57                	ja     80020b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b8:	4b                   	dec    %ebx
  8001b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d3:	00 
  8001d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	e8 92 0b 00 00       	call   800d78 <__udivdi3>
  8001e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	89 fa                	mov    %edi,%edx
  8001f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fa:	e8 89 ff ff ff       	call   800188 <printnum>
  8001ff:	eb 0f                	jmp    800210 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800205:	89 34 24             	mov    %esi,(%esp)
  800208:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020b:	4b                   	dec    %ebx
  80020c:	85 db                	test   %ebx,%ebx
  80020e:	7f f1                	jg     800201 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800210:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800214:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800218:	8b 45 10             	mov    0x10(%ebp),%eax
  80021b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800226:	00 
  800227:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022a:	89 04 24             	mov    %eax,(%esp)
  80022d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	e8 5f 0c 00 00       	call   800e98 <__umoddi3>
  800239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023d:	0f be 80 f8 0f 80 00 	movsbl 0x800ff8(%eax),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024a:	83 c4 3c             	add    $0x3c,%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800255:	83 fa 01             	cmp    $0x1,%edx
  800258:	7e 0e                	jle    800268 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	8b 52 04             	mov    0x4(%edx),%edx
  800266:	eb 22                	jmp    80028a <getuint+0x38>
	else if (lflag)
  800268:	85 d2                	test   %edx,%edx
  80026a:	74 10                	je     80027c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	eb 0e                	jmp    80028a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800292:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800295:	8b 10                	mov    (%eax),%edx
  800297:	3b 50 04             	cmp    0x4(%eax),%edx
  80029a:	73 08                	jae    8002a4 <sprintputch+0x18>
		*b->buf++ = ch;
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	88 0a                	mov    %cl,(%edx)
  8002a1:	42                   	inc    %edx
  8002a2:	89 10                	mov    %edx,(%eax)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c4:	89 04 24             	mov    %eax,(%esp)
  8002c7:	e8 02 00 00 00       	call   8002ce <vprintfmt>
	va_end(ap);
}
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 4c             	sub    $0x4c,%esp
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 75 10             	mov    0x10(%ebp),%esi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 6b 03 00 00    	je     800652 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002eb:	89 04 24             	mov    %eax,(%esp)
  8002ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	0f b6 06             	movzbl (%esi),%eax
  8002f4:	46                   	inc    %esi
  8002f5:	83 f8 25             	cmp    $0x25,%eax
  8002f8:	75 e5                	jne    8002df <vprintfmt+0x11>
  8002fa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800305:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800311:	b9 00 00 00 00       	mov    $0x0,%ecx
  800316:	eb 26                	jmp    80033e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80031f:	eb 1d                	jmp    80033e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800324:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800328:	eb 14                	jmp    80033e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80032d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800334:	eb 08                	jmp    80033e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800336:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800339:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	0f b6 06             	movzbl (%esi),%eax
  800341:	8d 56 01             	lea    0x1(%esi),%edx
  800344:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800347:	8a 16                	mov    (%esi),%dl
  800349:	83 ea 23             	sub    $0x23,%edx
  80034c:	80 fa 55             	cmp    $0x55,%dl
  80034f:	0f 87 e1 02 00 00    	ja     800636 <vprintfmt+0x368>
  800355:	0f b6 d2             	movzbl %dl,%edx
  800358:	ff 24 95 c0 10 80 00 	jmp    *0x8010c0(,%edx,4)
  80035f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800362:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800367:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80036a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80036e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800371:	8d 50 d0             	lea    -0x30(%eax),%edx
  800374:	83 fa 09             	cmp    $0x9,%edx
  800377:	77 2a                	ja     8003a3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800379:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037a:	eb eb                	jmp    800367 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 50 04             	lea    0x4(%eax),%edx
  800382:	89 55 14             	mov    %edx,0x14(%ebp)
  800385:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 17                	jmp    8003a3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80038c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800390:	78 98                	js     80032a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800395:	eb a7                	jmp    80033e <vprintfmt+0x70>
  800397:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a1:	eb 9b                	jmp    80033e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a7:	79 95                	jns    80033e <vprintfmt+0x70>
  8003a9:	eb 8b                	jmp    800336 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003af:	eb 8d                	jmp    80033e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 50 04             	lea    0x4(%eax),%edx
  8003b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c9:	e9 23 ff ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	79 02                	jns    8003df <vprintfmt+0x111>
  8003dd:	f7 d8                	neg    %eax
  8003df:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e1:	83 f8 09             	cmp    $0x9,%eax
  8003e4:	7f 0b                	jg     8003f1 <vprintfmt+0x123>
  8003e6:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	75 23                	jne    800414 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f5:	c7 44 24 08 10 10 80 	movl   $0x801010,0x8(%esp)
  8003fc:	00 
  8003fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	e8 9a fe ff ff       	call   8002a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040f:	e9 dd fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800414:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800418:	c7 44 24 08 19 10 80 	movl   $0x801019,0x8(%esp)
  80041f:	00 
  800420:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	89 14 24             	mov    %edx,(%esp)
  80042a:	e8 77 fe ff ff       	call   8002a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800432:	e9 ba fe ff ff       	jmp    8002f1 <vprintfmt+0x23>
  800437:	89 f9                	mov    %edi,%ecx
  800439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 30                	mov    (%eax),%esi
  80044a:	85 f6                	test   %esi,%esi
  80044c:	75 05                	jne    800453 <vprintfmt+0x185>
				p = "(null)";
  80044e:	be 09 10 80 00       	mov    $0x801009,%esi
			if (width > 0 && padc != '-')
  800453:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800457:	0f 8e 84 00 00 00    	jle    8004e1 <vprintfmt+0x213>
  80045d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800461:	74 7e                	je     8004e1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800467:	89 34 24             	mov    %esi,(%esp)
  80046a:	e8 8b 02 00 00       	call   8006fa <strnlen>
  80046f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800472:	29 c2                	sub    %eax,%edx
  800474:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800477:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80047b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80047e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800481:	89 de                	mov    %ebx,%esi
  800483:	89 d3                	mov    %edx,%ebx
  800485:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	eb 0b                	jmp    800494 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800489:	89 74 24 04          	mov    %esi,0x4(%esp)
  80048d:	89 3c 24             	mov    %edi,(%esp)
  800490:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	4b                   	dec    %ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	7f f1                	jg     800489 <vprintfmt+0x1bb>
  800498:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049b:	89 f3                	mov    %esi,%ebx
  80049d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	79 05                	jns    8004ac <vprintfmt+0x1de>
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004af:	29 c2                	sub    %eax,%edx
  8004b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b4:	eb 2b                	jmp    8004e1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ba:	74 18                	je     8004d4 <vprintfmt+0x206>
  8004bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bf:	83 fa 5e             	cmp    $0x5e,%edx
  8004c2:	76 10                	jbe    8004d4 <vprintfmt+0x206>
					putch('?', putdat);
  8004c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	eb 0a                	jmp    8004de <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004de:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e1:	0f be 06             	movsbl (%esi),%eax
  8004e4:	46                   	inc    %esi
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	74 21                	je     80050a <vprintfmt+0x23c>
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	78 c9                	js     8004b6 <vprintfmt+0x1e8>
  8004ed:	4f                   	dec    %edi
  8004ee:	79 c6                	jns    8004b6 <vprintfmt+0x1e8>
  8004f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f3:	89 de                	mov    %ebx,%esi
  8004f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f8:	eb 18                	jmp    800512 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800505:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800507:	4b                   	dec    %ebx
  800508:	eb 08                	jmp    800512 <vprintfmt+0x244>
  80050a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050d:	89 de                	mov    %ebx,%esi
  80050f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800512:	85 db                	test   %ebx,%ebx
  800514:	7f e4                	jg     8004fa <vprintfmt+0x22c>
  800516:	89 7d 08             	mov    %edi,0x8(%ebp)
  800519:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	e9 ce fd ff ff       	jmp    8002f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800523:	83 f9 01             	cmp    $0x1,%ecx
  800526:	7e 10                	jle    800538 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 08             	lea    0x8(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 30                	mov    (%eax),%esi
  800533:	8b 78 04             	mov    0x4(%eax),%edi
  800536:	eb 26                	jmp    80055e <vprintfmt+0x290>
	else if (lflag)
  800538:	85 c9                	test   %ecx,%ecx
  80053a:	74 12                	je     80054e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 04             	lea    0x4(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 30                	mov    (%eax),%esi
  800547:	89 f7                	mov    %esi,%edi
  800549:	c1 ff 1f             	sar    $0x1f,%edi
  80054c:	eb 10                	jmp    80055e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 30                	mov    (%eax),%esi
  800559:	89 f7                	mov    %esi,%edi
  80055b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055e:	85 ff                	test   %edi,%edi
  800560:	78 0a                	js     80056c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	e9 8c 00 00 00       	jmp    8005f8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800577:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057a:	f7 de                	neg    %esi
  80057c:	83 d7 00             	adc    $0x0,%edi
  80057f:	f7 df                	neg    %edi
			}
			base = 10;
  800581:	b8 0a 00 00 00       	mov    $0xa,%eax
  800586:	eb 70                	jmp    8005f8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800588:	89 ca                	mov    %ecx,%edx
  80058a:	8d 45 14             	lea    0x14(%ebp),%eax
  80058d:	e8 c0 fc ff ff       	call   800252 <getuint>
  800592:	89 c6                	mov    %eax,%esi
  800594:	89 d7                	mov    %edx,%edi
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059b:	eb 5b                	jmp    8005f8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  80059d:	89 ca                	mov    %ecx,%edx
  80059f:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a2:	e8 ab fc ff ff       	call   800252 <getuint>
  8005a7:	89 c6                	mov    %eax,%esi
  8005a9:	89 d7                	mov    %edx,%edi
                        base = 8;
  8005ab:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8005b0:	eb 46                	jmp    8005f8 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8005b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d7:	8b 30                	mov    (%eax),%esi
  8005d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005e3:	eb 13                	jmp    8005f8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e5:	89 ca                	mov    %ecx,%edx
  8005e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ea:	e8 63 fc ff ff       	call   800252 <getuint>
  8005ef:	89 c6                	mov    %eax,%esi
  8005f1:	89 d7                	mov    %edx,%edi
			base = 16;
  8005f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800603:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800607:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060b:	89 34 24             	mov    %esi,(%esp)
  80060e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800612:	89 da                	mov    %ebx,%edx
  800614:	8b 45 08             	mov    0x8(%ebp),%eax
  800617:	e8 6c fb ff ff       	call   800188 <printnum>
			break;
  80061c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061f:	e9 cd fc ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800631:	e9 bb fc ff ff       	jmp    8002f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800641:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800644:	eb 01                	jmp    800647 <vprintfmt+0x379>
  800646:	4e                   	dec    %esi
  800647:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064b:	75 f9                	jne    800646 <vprintfmt+0x378>
  80064d:	e9 9f fc ff ff       	jmp    8002f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800652:	83 c4 4c             	add    $0x4c,%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
  80065d:	83 ec 28             	sub    $0x28,%esp
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800666:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800669:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800670:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800677:	85 c0                	test   %eax,%eax
  800679:	74 30                	je     8006ab <vsnprintf+0x51>
  80067b:	85 d2                	test   %edx,%edx
  80067d:	7e 33                	jle    8006b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800686:	8b 45 10             	mov    0x10(%ebp),%eax
  800689:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800690:	89 44 24 04          	mov    %eax,0x4(%esp)
  800694:	c7 04 24 8c 02 80 00 	movl   $0x80028c,(%esp)
  80069b:	e8 2e fc ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a9:	eb 0c                	jmp    8006b7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b0:	eb 05                	jmp    8006b7 <vsnprintf+0x5d>
  8006b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b7:	c9                   	leave  
  8006b8:	c3                   	ret    

008006b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	e8 7b ff ff ff       	call   80065a <vsnprintf>
	va_end(ap);

	return rc;
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    
  8006e1:	00 00                	add    %al,(%eax)
	...

008006e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	eb 01                	jmp    8006f2 <strlen+0xe>
		n++;
  8006f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f6:	75 f9                	jne    8006f1 <strlen+0xd>
		n++;
	return n;
}
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 01                	jmp    80070b <strnlen+0x11>
		n++;
  80070a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	39 d0                	cmp    %edx,%eax
  80070d:	74 06                	je     800715 <strnlen+0x1b>
  80070f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800713:	75 f5                	jne    80070a <strnlen+0x10>
		n++;
	return n;
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800729:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80072c:	42                   	inc    %edx
  80072d:	84 c9                	test   %cl,%cl
  80072f:	75 f5                	jne    800726 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800731:	5b                   	pop    %ebx
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	53                   	push   %ebx
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073e:	89 1c 24             	mov    %ebx,(%esp)
  800741:	e8 9e ff ff ff       	call   8006e4 <strlen>
	strcpy(dst + len, src);
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
  800749:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074d:	01 d8                	add    %ebx,%eax
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	e8 c0 ff ff ff       	call   800717 <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	83 c4 08             	add    $0x8,%esp
  80075c:	5b                   	pop    %ebx
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800772:	eb 0c                	jmp    800780 <strncpy+0x21>
		*dst++ = *src;
  800774:	8a 1a                	mov    (%edx),%bl
  800776:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800779:	80 3a 01             	cmpb   $0x1,(%edx)
  80077c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	41                   	inc    %ecx
  800780:	39 f1                	cmp    %esi,%ecx
  800782:	75 f0                	jne    800774 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800796:	85 d2                	test   %edx,%edx
  800798:	75 0a                	jne    8007a4 <strlcpy+0x1c>
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	eb 1a                	jmp    8007b8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079e:	88 18                	mov    %bl,(%eax)
  8007a0:	40                   	inc    %eax
  8007a1:	41                   	inc    %ecx
  8007a2:	eb 02                	jmp    8007a6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007a6:	4a                   	dec    %edx
  8007a7:	74 0a                	je     8007b3 <strlcpy+0x2b>
  8007a9:	8a 19                	mov    (%ecx),%bl
  8007ab:	84 db                	test   %bl,%bl
  8007ad:	75 ef                	jne    80079e <strlcpy+0x16>
  8007af:	89 c2                	mov    %eax,%edx
  8007b1:	eb 02                	jmp    8007b5 <strlcpy+0x2d>
  8007b3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b8:	29 f0                	sub    %esi,%eax
}
  8007ba:	5b                   	pop    %ebx
  8007bb:	5e                   	pop    %esi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c7:	eb 02                	jmp    8007cb <strcmp+0xd>
		p++, q++;
  8007c9:	41                   	inc    %ecx
  8007ca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cb:	8a 01                	mov    (%ecx),%al
  8007cd:	84 c0                	test   %al,%al
  8007cf:	74 04                	je     8007d5 <strcmp+0x17>
  8007d1:	3a 02                	cmp    (%edx),%al
  8007d3:	74 f4                	je     8007c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d5:	0f b6 c0             	movzbl %al,%eax
  8007d8:	0f b6 12             	movzbl (%edx),%edx
  8007db:	29 d0                	sub    %edx,%eax
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007ec:	eb 03                	jmp    8007f1 <strncmp+0x12>
		n--, p++, q++;
  8007ee:	4a                   	dec    %edx
  8007ef:	40                   	inc    %eax
  8007f0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 14                	je     800809 <strncmp+0x2a>
  8007f5:	8a 18                	mov    (%eax),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	74 04                	je     8007ff <strncmp+0x20>
  8007fb:	3a 19                	cmp    (%ecx),%bl
  8007fd:	74 ef                	je     8007ee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 00             	movzbl (%eax),%eax
  800802:	0f b6 11             	movzbl (%ecx),%edx
  800805:	29 d0                	sub    %edx,%eax
  800807:	eb 05                	jmp    80080e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081a:	eb 05                	jmp    800821 <strchr+0x10>
		if (*s == c)
  80081c:	38 ca                	cmp    %cl,%dl
  80081e:	74 0c                	je     80082c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800820:	40                   	inc    %eax
  800821:	8a 10                	mov    (%eax),%dl
  800823:	84 d2                	test   %dl,%dl
  800825:	75 f5                	jne    80081c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800837:	eb 05                	jmp    80083e <strfind+0x10>
		if (*s == c)
  800839:	38 ca                	cmp    %cl,%dl
  80083b:	74 07                	je     800844 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80083d:	40                   	inc    %eax
  80083e:	8a 10                	mov    (%eax),%dl
  800840:	84 d2                	test   %dl,%dl
  800842:	75 f5                	jne    800839 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	57                   	push   %edi
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	74 30                	je     800889 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800859:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085f:	75 25                	jne    800886 <memset+0x40>
  800861:	f6 c1 03             	test   $0x3,%cl
  800864:	75 20                	jne    800886 <memset+0x40>
		c &= 0xFF;
  800866:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800869:	89 d3                	mov    %edx,%ebx
  80086b:	c1 e3 08             	shl    $0x8,%ebx
  80086e:	89 d6                	mov    %edx,%esi
  800870:	c1 e6 18             	shl    $0x18,%esi
  800873:	89 d0                	mov    %edx,%eax
  800875:	c1 e0 10             	shl    $0x10,%eax
  800878:	09 f0                	or     %esi,%eax
  80087a:	09 d0                	or     %edx,%eax
  80087c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80087e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800881:	fc                   	cld    
  800882:	f3 ab                	rep stos %eax,%es:(%edi)
  800884:	eb 03                	jmp    800889 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800886:	fc                   	cld    
  800887:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800889:	89 f8                	mov    %edi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5f                   	pop    %edi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	57                   	push   %edi
  800894:	56                   	push   %esi
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089e:	39 c6                	cmp    %eax,%esi
  8008a0:	73 34                	jae    8008d6 <memmove+0x46>
  8008a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a5:	39 d0                	cmp    %edx,%eax
  8008a7:	73 2d                	jae    8008d6 <memmove+0x46>
		s += n;
		d += n;
  8008a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ac:	f6 c2 03             	test   $0x3,%dl
  8008af:	75 1b                	jne    8008cc <memmove+0x3c>
  8008b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b7:	75 13                	jne    8008cc <memmove+0x3c>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 0e                	jne    8008cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008be:	83 ef 04             	sub    $0x4,%edi
  8008c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008c7:	fd                   	std    
  8008c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ca:	eb 07                	jmp    8008d3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008cc:	4f                   	dec    %edi
  8008cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d0:	fd                   	std    
  8008d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d3:	fc                   	cld    
  8008d4:	eb 20                	jmp    8008f6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008dc:	75 13                	jne    8008f1 <memmove+0x61>
  8008de:	a8 03                	test   $0x3,%al
  8008e0:	75 0f                	jne    8008f1 <memmove+0x61>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 0a                	jne    8008f1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ea:	89 c7                	mov    %eax,%edi
  8008ec:	fc                   	cld    
  8008ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ef:	eb 05                	jmp    8008f6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f1:	89 c7                	mov    %eax,%edi
  8008f3:	fc                   	cld    
  8008f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f6:	5e                   	pop    %esi
  8008f7:	5f                   	pop    %edi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800900:	8b 45 10             	mov    0x10(%ebp),%eax
  800903:	89 44 24 08          	mov    %eax,0x8(%esp)
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	89 04 24             	mov    %eax,(%esp)
  800914:	e8 77 ff ff ff       	call   800890 <memmove>
}
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	8b 7d 08             	mov    0x8(%ebp),%edi
  800924:	8b 75 0c             	mov    0xc(%ebp),%esi
  800927:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092a:	ba 00 00 00 00       	mov    $0x0,%edx
  80092f:	eb 16                	jmp    800947 <memcmp+0x2c>
		if (*s1 != *s2)
  800931:	8a 04 17             	mov    (%edi,%edx,1),%al
  800934:	42                   	inc    %edx
  800935:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800939:	38 c8                	cmp    %cl,%al
  80093b:	74 0a                	je     800947 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80093d:	0f b6 c0             	movzbl %al,%eax
  800940:	0f b6 c9             	movzbl %cl,%ecx
  800943:	29 c8                	sub    %ecx,%eax
  800945:	eb 09                	jmp    800950 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	39 da                	cmp    %ebx,%edx
  800949:	75 e6                	jne    800931 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095e:	89 c2                	mov    %eax,%edx
  800960:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800963:	eb 05                	jmp    80096a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800965:	38 08                	cmp    %cl,(%eax)
  800967:	74 05                	je     80096e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800969:	40                   	inc    %eax
  80096a:	39 d0                	cmp    %edx,%eax
  80096c:	72 f7                	jb     800965 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 55 08             	mov    0x8(%ebp),%edx
  800979:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	eb 01                	jmp    80097f <strtol+0xf>
		s++;
  80097e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097f:	8a 02                	mov    (%edx),%al
  800981:	3c 20                	cmp    $0x20,%al
  800983:	74 f9                	je     80097e <strtol+0xe>
  800985:	3c 09                	cmp    $0x9,%al
  800987:	74 f5                	je     80097e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800989:	3c 2b                	cmp    $0x2b,%al
  80098b:	75 08                	jne    800995 <strtol+0x25>
		s++;
  80098d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098e:	bf 00 00 00 00       	mov    $0x0,%edi
  800993:	eb 13                	jmp    8009a8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800995:	3c 2d                	cmp    $0x2d,%al
  800997:	75 0a                	jne    8009a3 <strtol+0x33>
		s++, neg = 1;
  800999:	8d 52 01             	lea    0x1(%edx),%edx
  80099c:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a1:	eb 05                	jmp    8009a8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a8:	85 db                	test   %ebx,%ebx
  8009aa:	74 05                	je     8009b1 <strtol+0x41>
  8009ac:	83 fb 10             	cmp    $0x10,%ebx
  8009af:	75 28                	jne    8009d9 <strtol+0x69>
  8009b1:	8a 02                	mov    (%edx),%al
  8009b3:	3c 30                	cmp    $0x30,%al
  8009b5:	75 10                	jne    8009c7 <strtol+0x57>
  8009b7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009bb:	75 0a                	jne    8009c7 <strtol+0x57>
		s += 2, base = 16;
  8009bd:	83 c2 02             	add    $0x2,%edx
  8009c0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c5:	eb 12                	jmp    8009d9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009c7:	85 db                	test   %ebx,%ebx
  8009c9:	75 0e                	jne    8009d9 <strtol+0x69>
  8009cb:	3c 30                	cmp    $0x30,%al
  8009cd:	75 05                	jne    8009d4 <strtol+0x64>
		s++, base = 8;
  8009cf:	42                   	inc    %edx
  8009d0:	b3 08                	mov    $0x8,%bl
  8009d2:	eb 05                	jmp    8009d9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009de:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e0:	8a 0a                	mov    (%edx),%cl
  8009e2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e5:	80 fb 09             	cmp    $0x9,%bl
  8009e8:	77 08                	ja     8009f2 <strtol+0x82>
			dig = *s - '0';
  8009ea:	0f be c9             	movsbl %cl,%ecx
  8009ed:	83 e9 30             	sub    $0x30,%ecx
  8009f0:	eb 1e                	jmp    800a10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009f2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f5:	80 fb 19             	cmp    $0x19,%bl
  8009f8:	77 08                	ja     800a02 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009fa:	0f be c9             	movsbl %cl,%ecx
  8009fd:	83 e9 57             	sub    $0x57,%ecx
  800a00:	eb 0e                	jmp    800a10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a05:	80 fb 19             	cmp    $0x19,%bl
  800a08:	77 12                	ja     800a1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a0a:	0f be c9             	movsbl %cl,%ecx
  800a0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a10:	39 f1                	cmp    %esi,%ecx
  800a12:	7d 0c                	jge    800a20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a14:	42                   	inc    %edx
  800a15:	0f af c6             	imul   %esi,%eax
  800a18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a1a:	eb c4                	jmp    8009e0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	89 c1                	mov    %eax,%ecx
  800a1e:	eb 02                	jmp    800a22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a26:	74 05                	je     800a2d <strtol+0xbd>
		*endptr = (char *) s;
  800a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a2d:	85 ff                	test   %edi,%edi
  800a2f:	74 04                	je     800a35 <strtol+0xc5>
  800a31:	89 c8                	mov    %ecx,%eax
  800a33:	f7 d8                	neg    %eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
	...

00800a3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4d:	89 c3                	mov    %eax,%ebx
  800a4f:	89 c7                	mov    %eax,%edi
  800a51:	89 c6                	mov    %eax,%esi
  800a53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a60:	ba 00 00 00 00       	mov    $0x0,%edx
  800a65:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6a:	89 d1                	mov    %edx,%ecx
  800a6c:	89 d3                	mov    %edx,%ebx
  800a6e:	89 d7                	mov    %edx,%edi
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a87:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	89 cb                	mov    %ecx,%ebx
  800a91:	89 cf                	mov    %ecx,%edi
  800a93:	89 ce                	mov    %ecx,%esi
  800a95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a97:	85 c0                	test   %eax,%eax
  800a99:	7e 28                	jle    800ac3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aa6:	00 
  800aa7:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800aae:	00 
  800aaf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ab6:	00 
  800ab7:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800abe:	e8 5d 02 00 00       	call   800d20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac3:	83 c4 2c             	add    $0x2c,%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 02 00 00 00       	mov    $0x2,%eax
  800adb:	89 d1                	mov    %edx,%ecx
  800add:	89 d3                	mov    %edx,%ebx
  800adf:	89 d7                	mov    %edx,%edi
  800ae1:	89 d6                	mov    %edx,%esi
  800ae3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_yield>:

void
sys_yield(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	be 00 00 00 00       	mov    $0x0,%esi
  800b17:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 f7                	mov    %esi,%edi
  800b27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	7e 28                	jle    800b55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b38:	00 
  800b39:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800b40:	00 
  800b41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b48:	00 
  800b49:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800b50:	e8 cb 01 00 00       	call   800d20 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b55:	83 c4 2c             	add    $0x2c,%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b66:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 28                	jle    800ba8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b8b:	00 
  800b8c:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800b93:	00 
  800b94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9b:	00 
  800b9c:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800ba3:	e8 78 01 00 00       	call   800d20 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba8:	83 c4 2c             	add    $0x2c,%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 df                	mov    %ebx,%edi
  800bcb:	89 de                	mov    %ebx,%esi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 28                	jle    800bfb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bde:	00 
  800bdf:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800be6:	00 
  800be7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bee:	00 
  800bef:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800bf6:	e8 25 01 00 00       	call   800d20 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	83 c4 2c             	add    $0x2c,%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 28                	jle    800c4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c31:	00 
  800c32:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800c39:	00 
  800c3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c41:	00 
  800c42:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800c49:	e8 d2 00 00 00       	call   800d20 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4e:	83 c4 2c             	add    $0x2c,%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c64:	b8 09 00 00 00       	mov    $0x9,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 df                	mov    %ebx,%edi
  800c71:	89 de                	mov    %ebx,%esi
  800c73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 28                	jle    800ca1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c84:	00 
  800c85:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c94:	00 
  800c95:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800c9c:	e8 7f 00 00 00       	call   800d20 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	83 c4 2c             	add    $0x2c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 28                	jle    800d16 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cf9:	00 
  800cfa:	c7 44 24 08 48 12 80 	movl   $0x801248,0x8(%esp)
  800d01:	00 
  800d02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d09:	00 
  800d0a:	c7 04 24 65 12 80 00 	movl   $0x801265,(%esp)
  800d11:	e8 0a 00 00 00       	call   800d20 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d16:	83 c4 2c             	add    $0x2c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
	...

00800d20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d28:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d2b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d31:	e8 95 fd ff ff       	call   800acb <sys_getenvid>
  800d36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d39:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4c:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800d53:	e8 14 f4 ff ff       	call   80016c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d58:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 a4 f3 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  800d67:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800d6e:	e8 f9 f3 ff ff       	call   80016c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d73:	cc                   	int3   
  800d74:	eb fd                	jmp    800d73 <_panic+0x53>
	...

00800d78 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d78:	55                   	push   %ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	83 ec 10             	sub    $0x10,%esp
  800d7e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d8e:	89 cd                	mov    %ecx,%ebp
  800d90:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	75 2c                	jne    800dc4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d98:	39 f9                	cmp    %edi,%ecx
  800d9a:	77 68                	ja     800e04 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d9c:	85 c9                	test   %ecx,%ecx
  800d9e:	75 0b                	jne    800dab <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800da0:	b8 01 00 00 00       	mov    $0x1,%eax
  800da5:	31 d2                	xor    %edx,%edx
  800da7:	f7 f1                	div    %ecx
  800da9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	89 f8                	mov    %edi,%eax
  800daf:	f7 f1                	div    %ecx
  800db1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	f7 f1                	div    %ecx
  800db7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dc4:	39 f8                	cmp    %edi,%eax
  800dc6:	77 2c                	ja     800df4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dc8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dcb:	83 f6 1f             	xor    $0x1f,%esi
  800dce:	75 4c                	jne    800e1c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd7:	72 0a                	jb     800de3 <__udivdi3+0x6b>
  800dd9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ddd:	0f 87 ad 00 00 00    	ja     800e90 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800de3:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800df8:	89 f0                	mov    %esi,%eax
  800dfa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e04:	89 fa                	mov    %edi,%edx
  800e06:	89 f0                	mov    %esi,%eax
  800e08:	f7 f1                	div    %ecx
  800e0a:	89 c6                	mov    %eax,%esi
  800e0c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e1c:	89 f1                	mov    %esi,%ecx
  800e1e:	d3 e0                	shl    %cl,%eax
  800e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e24:	b8 20 00 00 00       	mov    $0x20,%eax
  800e29:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e2b:	89 ea                	mov    %ebp,%edx
  800e2d:	88 c1                	mov    %al,%cl
  800e2f:	d3 ea                	shr    %cl,%edx
  800e31:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e35:	09 ca                	or     %ecx,%edx
  800e37:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e3b:	89 f1                	mov    %esi,%ecx
  800e3d:	d3 e5                	shl    %cl,%ebp
  800e3f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e43:	89 fd                	mov    %edi,%ebp
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e49:	89 fa                	mov    %edi,%edx
  800e4b:	89 f1                	mov    %esi,%ecx
  800e4d:	d3 e2                	shl    %cl,%edx
  800e4f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e53:	88 c1                	mov    %al,%cl
  800e55:	d3 ef                	shr    %cl,%edi
  800e57:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	89 ea                	mov    %ebp,%edx
  800e5d:	f7 74 24 08          	divl   0x8(%esp)
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e65:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e69:	39 d1                	cmp    %edx,%ecx
  800e6b:	72 17                	jb     800e84 <__udivdi3+0x10c>
  800e6d:	74 09                	je     800e78 <__udivdi3+0x100>
  800e6f:	89 fe                	mov    %edi,%esi
  800e71:	31 ff                	xor    %edi,%edi
  800e73:	e9 41 ff ff ff       	jmp    800db9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e78:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e7c:	89 f1                	mov    %esi,%ecx
  800e7e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e80:	39 c2                	cmp    %eax,%edx
  800e82:	73 eb                	jae    800e6f <__udivdi3+0xf7>
		{
		  q0--;
  800e84:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e87:	31 ff                	xor    %edi,%edi
  800e89:	e9 2b ff ff ff       	jmp    800db9 <__udivdi3+0x41>
  800e8e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e90:	31 f6                	xor    %esi,%esi
  800e92:	e9 22 ff ff ff       	jmp    800db9 <__udivdi3+0x41>
	...

00800e98 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e98:	55                   	push   %ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	83 ec 20             	sub    $0x20,%esp
  800e9e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ea2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ea6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eaa:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800eae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eb2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eb6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800eb8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eba:	85 ed                	test   %ebp,%ebp
  800ebc:	75 16                	jne    800ed4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800ebe:	39 f1                	cmp    %esi,%ecx
  800ec0:	0f 86 a6 00 00 00    	jbe    800f6c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed4:	39 f5                	cmp    %esi,%ebp
  800ed6:	0f 87 ac 00 00 00    	ja     800f88 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800edc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800edf:	83 f0 1f             	xor    $0x1f,%eax
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	0f 84 a8 00 00 00    	je     800f94 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ef2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800efb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eff:	89 f9                	mov    %edi,%ecx
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	09 e8                	or     %ebp,%eax
  800f05:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f09:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f0d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f11:	d3 e0                	shl    %cl,%eax
  800f13:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f17:	89 f2                	mov    %esi,%edx
  800f19:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f1b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f1f:	d3 e0                	shl    %cl,%eax
  800f21:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f25:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f29:	89 f9                	mov    %edi,%ecx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f2f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	f7 74 24 18          	divl   0x18(%esp)
  800f37:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f39:	f7 64 24 0c          	mull   0xc(%esp)
  800f3d:	89 c5                	mov    %eax,%ebp
  800f3f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f41:	39 d6                	cmp    %edx,%esi
  800f43:	72 67                	jb     800fac <__umoddi3+0x114>
  800f45:	74 75                	je     800fbc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f47:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f4b:	29 e8                	sub    %ebp,%eax
  800f4d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f53:	d3 e8                	shr    %cl,%eax
  800f55:	89 f2                	mov    %esi,%edx
  800f57:	89 f9                	mov    %edi,%ecx
  800f59:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f5b:	09 d0                	or     %edx,%eax
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f63:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f65:	83 c4 20             	add    $0x20,%esp
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f6c:	85 c9                	test   %ecx,%ecx
  800f6e:	75 0b                	jne    800f7b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f70:	b8 01 00 00 00       	mov    $0x1,%eax
  800f75:	31 d2                	xor    %edx,%edx
  800f77:	f7 f1                	div    %ecx
  800f79:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f7b:	89 f0                	mov    %esi,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f81:	89 f8                	mov    %edi,%eax
  800f83:	e9 3e ff ff ff       	jmp    800ec6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f88:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
  800f91:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f94:	39 f5                	cmp    %esi,%ebp
  800f96:	72 04                	jb     800f9c <__umoddi3+0x104>
  800f98:	39 f9                	cmp    %edi,%ecx
  800f9a:	77 06                	ja     800fa2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	29 cf                	sub    %ecx,%edi
  800fa0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fa2:	89 f8                	mov    %edi,%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fac:	89 d1                	mov    %edx,%ecx
  800fae:	89 c5                	mov    %eax,%ebp
  800fb0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fb4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fb8:	eb 8d                	jmp    800f47 <__umoddi3+0xaf>
  800fba:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fbc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fc0:	72 ea                	jb     800fac <__umoddi3+0x114>
  800fc2:	89 f1                	mov    %esi,%ecx
  800fc4:	eb 81                	jmp    800f47 <__umoddi3+0xaf>
