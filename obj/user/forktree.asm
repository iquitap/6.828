
obj/user/forktree：     文件格式 elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 18 0b 00 00       	call   800b5b <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 40 15 80 00 	movl   $0x801540,(%esp)
  800052:	e8 a5 01 00 00       	call   8001fc <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 df 06 00 00       	call   800774 <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 51 15 80 	movl   $0x801551,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 88 06 00 00       	call   800749 <snprintf>
	if (fork() == 0) {
  8000c1:	e8 26 0e 00 00       	call   800eec <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 6e 00 00 00       	call   800148 <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 10 19 80 00 	movl   $0x801910,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800102:	e8 54 0a 00 00       	call   800b5b <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800113:	c1 e0 07             	shl    $0x7,%eax
  800116:	29 d0                	sub    %edx,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 f6                	test   %esi,%esi
  800124:	7e 07                	jle    80012d <libmain+0x39>
		binaryname = argv[0];
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800131:	89 34 24             	mov    %esi,(%esp)
  800134:	e8 a7 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    
  800145:	00 00                	add    %al,(%eax)
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 af 09 00 00       	call   800b09 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 14             	sub    $0x14,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 19                	jne    800192 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800179:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800180:	00 
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	e8 40 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800192:	ff 43 04             	incl   0x4(%ebx)
}
  800195:	83 c4 14             	add    $0x14,%esp
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 5c 01 80 00 	movl   $0x80015c,(%esp)
  8001d7:	e8 82 01 00 00       	call   80035e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 d8 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	89 44 24 04          	mov    %eax,0x4(%esp)
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	e8 87 ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  800214:	c9                   	leave  
  800215:	c3                   	ret    
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 3c             	sub    $0x3c,%esp
  800221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800224:	89 d7                	mov    %edx,%edi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800235:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800238:	85 c0                	test   %eax,%eax
  80023a:	75 08                	jne    800244 <printnum+0x2c>
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 57                	ja     80029b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 74 24 10          	mov    %esi,0x10(%esp)
  800248:	4b                   	dec    %ebx
  800249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800258:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80025c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800263:	00 
  800264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	e8 72 10 00 00       	call   8012e8 <__udivdi3>
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	89 54 24 04          	mov    %edx,0x4(%esp)
  800285:	89 fa                	mov    %edi,%edx
  800287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028a:	e8 89 ff ff ff       	call   800218 <printnum>
  80028f:	eb 0f                	jmp    8002a0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	89 34 24             	mov    %esi,(%esp)
  800298:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029b:	4b                   	dec    %ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f f1                	jg     800291 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	e8 3f 11 00 00       	call   801408 <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 60 15 80 00 	movsbl 0x801560(%eax),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002da:	83 c4 3c             	add    $0x3c,%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 08                	jae    800334 <sprintputch+0x18>
		*b->buf++ = ch;
  80032c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032f:	88 0a                	mov    %cl,(%edx)
  800331:	42                   	inc    %edx
  800332:	89 10                	mov    %edx,(%eax)
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80033c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800343:	8b 45 10             	mov    0x10(%ebp),%eax
  800346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	e8 02 00 00 00       	call   80035e <vprintfmt>
	va_end(ap);
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 4c             	sub    $0x4c,%esp
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 75 10             	mov    0x10(%ebp),%esi
  80036d:	eb 12                	jmp    800381 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036f:	85 c0                	test   %eax,%eax
  800371:	0f 84 6b 03 00 00    	je     8006e2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800377:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	0f b6 06             	movzbl (%esi),%eax
  800384:	46                   	inc    %esi
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e5                	jne    80036f <vprintfmt+0x11>
  80038a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80038e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800395:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a6:	eb 26                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003af:	eb 1d                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b8:	eb 14                	jmp    8003ce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c4:	eb 08                	jmp    8003ce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	0f b6 06             	movzbl (%esi),%eax
  8003d1:	8d 56 01             	lea    0x1(%esi),%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003d7:	8a 16                	mov    (%esi),%dl
  8003d9:	83 ea 23             	sub    $0x23,%edx
  8003dc:	80 fa 55             	cmp    $0x55,%dl
  8003df:	0f 87 e1 02 00 00    	ja     8006c6 <vprintfmt+0x368>
  8003e5:	0f b6 d2             	movzbl %dl,%edx
  8003e8:	ff 24 95 20 16 80 00 	jmp    *0x801620(,%edx,4)
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003fa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003fe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800401:	8d 50 d0             	lea    -0x30(%eax),%edx
  800404:	83 fa 09             	cmp    $0x9,%edx
  800407:	77 2a                	ja     800433 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040a:	eb eb                	jmp    8003f7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041a:	eb 17                	jmp    800433 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80041c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800420:	78 98                	js     8003ba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800425:	eb a7                	jmp    8003ce <vprintfmt+0x70>
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800431:	eb 9b                	jmp    8003ce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800437:	79 95                	jns    8003ce <vprintfmt+0x70>
  800439:	eb 8b                	jmp    8003c6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043f:	eb 8d                	jmp    8003ce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 23 ff ff ff       	jmp    800381 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	79 02                	jns    80046f <vprintfmt+0x111>
  80046d:	f7 d8                	neg    %eax
  80046f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 09             	cmp    $0x9,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x123>
  800476:	8b 04 85 80 17 80 00 	mov    0x801780(,%eax,4),%eax
  80047d:	85 c0                	test   %eax,%eax
  80047f:	75 23                	jne    8004a4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800481:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800485:	c7 44 24 08 78 15 80 	movl   $0x801578,0x8(%esp)
  80048c:	00 
  80048d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 9a fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049f:	e9 dd fe ff ff       	jmp    800381 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a8:	c7 44 24 08 81 15 80 	movl   $0x801581,0x8(%esp)
  8004af:	00 
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	89 14 24             	mov    %edx,(%esp)
  8004ba:	e8 77 fe ff ff       	call   800336 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c2:	e9 ba fe ff ff       	jmp    800381 <vprintfmt+0x23>
  8004c7:	89 f9                	mov    %edi,%ecx
  8004c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 30                	mov    (%eax),%esi
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	75 05                	jne    8004e3 <vprintfmt+0x185>
				p = "(null)";
  8004de:	be 71 15 80 00       	mov    $0x801571,%esi
			if (width > 0 && padc != '-')
  8004e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e7:	0f 8e 84 00 00 00    	jle    800571 <vprintfmt+0x213>
  8004ed:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004f1:	74 7e                	je     800571 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f7:	89 34 24             	mov    %esi,(%esp)
  8004fa:	e8 8b 02 00 00       	call   80078a <strnlen>
  8004ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800502:	29 c2                	sub    %eax,%edx
  800504:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800507:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80050b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80050e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800511:	89 de                	mov    %ebx,%esi
  800513:	89 d3                	mov    %edx,%ebx
  800515:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	eb 0b                	jmp    800524 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051d:	89 3c 24             	mov    %edi,(%esp)
  800520:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <vprintfmt+0x1bb>
  800528:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80052b:	89 f3                	mov    %esi,%ebx
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	79 05                	jns    80053c <vprintfmt+0x1de>
  800537:	b8 00 00 00 00       	mov    $0x0,%eax
  80053c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053f:	29 c2                	sub    %eax,%edx
  800541:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800544:	eb 2b                	jmp    800571 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054a:	74 18                	je     800564 <vprintfmt+0x206>
  80054c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054f:	83 fa 5e             	cmp    $0x5e,%edx
  800552:	76 10                	jbe    800564 <vprintfmt+0x206>
					putch('?', putdat);
  800554:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800558:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	eb 0a                	jmp    80056e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	ff 4d e4             	decl   -0x1c(%ebp)
  800571:	0f be 06             	movsbl (%esi),%eax
  800574:	46                   	inc    %esi
  800575:	85 c0                	test   %eax,%eax
  800577:	74 21                	je     80059a <vprintfmt+0x23c>
  800579:	85 ff                	test   %edi,%edi
  80057b:	78 c9                	js     800546 <vprintfmt+0x1e8>
  80057d:	4f                   	dec    %edi
  80057e:	79 c6                	jns    800546 <vprintfmt+0x1e8>
  800580:	8b 7d 08             	mov    0x8(%ebp),%edi
  800583:	89 de                	mov    %ebx,%esi
  800585:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800588:	eb 18                	jmp    8005a2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800595:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	eb 08                	jmp    8005a2 <vprintfmt+0x244>
  80059a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059d:	89 de                	mov    %ebx,%esi
  80059f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	7f e4                	jg     80058a <vprintfmt+0x22c>
  8005a6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005a9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ce fd ff ff       	jmp    800381 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 f9 01             	cmp    $0x1,%ecx
  8005b6:	7e 10                	jle    8005c8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
  8005c3:	8b 78 04             	mov    0x4(%eax),%edi
  8005c6:	eb 26                	jmp    8005ee <vprintfmt+0x290>
	else if (lflag)
  8005c8:	85 c9                	test   %ecx,%ecx
  8005ca:	74 12                	je     8005de <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 30                	mov    (%eax),%esi
  8005d7:	89 f7                	mov    %esi,%edi
  8005d9:	c1 ff 1f             	sar    $0x1f,%edi
  8005dc:	eb 10                	jmp    8005ee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	89 f7                	mov    %esi,%edi
  8005eb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	78 0a                	js     8005fc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 8c 00 00 00       	jmp    800688 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800600:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060a:	f7 de                	neg    %esi
  80060c:	83 d7 00             	adc    $0x0,%edi
  80060f:	f7 df                	neg    %edi
			}
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	eb 70                	jmp    800688 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 c0 fc ff ff       	call   8002e2 <getuint>
  800622:	89 c6                	mov    %eax,%esi
  800624:	89 d7                	mov    %edx,%edi
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062b:	eb 5b                	jmp    800688 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  80062d:	89 ca                	mov    %ecx,%edx
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 ab fc ff ff       	call   8002e2 <getuint>
  800637:	89 c6                	mov    %eax,%esi
  800639:	89 d7                	mov    %edx,%edi
                        base = 8;
  80063b:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  800640:	eb 46                	jmp    800688 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  800642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800646:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800667:	8b 30                	mov    (%eax),%esi
  800669:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800673:	eb 13                	jmp    800688 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 63 fc ff ff       	call   8002e2 <getuint>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	89 d7                	mov    %edx,%edi
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80068c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069b:	89 34 24             	mov    %esi,(%esp)
  80069e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	e8 6c fb ff ff       	call   800218 <printnum>
			break;
  8006ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006af:	e9 cd fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c1:	e9 bb fc ff ff       	jmp    800381 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d4:	eb 01                	jmp    8006d7 <vprintfmt+0x379>
  8006d6:	4e                   	dec    %esi
  8006d7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006db:	75 f9                	jne    8006d6 <vprintfmt+0x378>
  8006dd:	e9 9f fc ff ff       	jmp    800381 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006e2:	83 c4 4c             	add    $0x4c,%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 28             	sub    $0x28,%esp
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800700:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800707:	85 c0                	test   %eax,%eax
  800709:	74 30                	je     80073b <vsnprintf+0x51>
  80070b:	85 d2                	test   %edx,%edx
  80070d:	7e 33                	jle    800742 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800716:	8b 45 10             	mov    0x10(%ebp),%eax
  800719:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800720:	89 44 24 04          	mov    %eax,0x4(%esp)
  800724:	c7 04 24 1c 03 80 00 	movl   $0x80031c,(%esp)
  80072b:	e8 2e fc ff ff       	call   80035e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	eb 0c                	jmp    800747 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800740:	eb 05                	jmp    800747 <vsnprintf+0x5d>
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800752:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800756:	8b 45 10             	mov    0x10(%ebp),%eax
  800759:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 7b ff ff ff       	call   8006ea <vsnprintf>
	va_end(ap);

	return rc;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
  800771:	00 00                	add    %al,(%eax)
	...

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	eb 01                	jmp    800782 <strlen+0xe>
		n++;
  800781:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f9                	jne    800781 <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 01                	jmp    80079b <strnlen+0x11>
		n++;
  80079a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1b>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f5                	jne    80079a <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007bc:	42                   	inc    %edx
  8007bd:	84 c9                	test   %cl,%cl
  8007bf:	75 f5                	jne    8007b6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	89 1c 24             	mov    %ebx,(%esp)
  8007d1:	e8 9e ff ff ff       	call   800774 <strlen>
	strcpy(dst + len, src);
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007dd:	01 d8                	add    %ebx,%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 c0 ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	eb 0c                	jmp    800810 <strncpy+0x21>
		*dst++ = *src;
  800804:	8a 1a                	mov    (%edx),%bl
  800806:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800809:	80 3a 01             	cmpb   $0x1,(%edx)
  80080c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	41                   	inc    %ecx
  800810:	39 f1                	cmp    %esi,%ecx
  800812:	75 f0                	jne    800804 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	75 0a                	jne    800834 <strlcpy+0x1c>
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	eb 1a                	jmp    800848 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082e:	88 18                	mov    %bl,(%eax)
  800830:	40                   	inc    %eax
  800831:	41                   	inc    %ecx
  800832:	eb 02                	jmp    800836 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800836:	4a                   	dec    %edx
  800837:	74 0a                	je     800843 <strlcpy+0x2b>
  800839:	8a 19                	mov    (%ecx),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	75 ef                	jne    80082e <strlcpy+0x16>
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 02                	jmp    800845 <strlcpy+0x2d>
  800843:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800845:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800857:	eb 02                	jmp    80085b <strcmp+0xd>
		p++, q++;
  800859:	41                   	inc    %ecx
  80085a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085b:	8a 01                	mov    (%ecx),%al
  80085d:	84 c0                	test   %al,%al
  80085f:	74 04                	je     800865 <strcmp+0x17>
  800861:	3a 02                	cmp    (%edx),%al
  800863:	74 f4                	je     800859 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 c0             	movzbl %al,%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80087c:	eb 03                	jmp    800881 <strncmp+0x12>
		n--, p++, q++;
  80087e:	4a                   	dec    %edx
  80087f:	40                   	inc    %eax
  800880:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800881:	85 d2                	test   %edx,%edx
  800883:	74 14                	je     800899 <strncmp+0x2a>
  800885:	8a 18                	mov    (%eax),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	74 04                	je     80088f <strncmp+0x20>
  80088b:	3a 19                	cmp    (%ecx),%bl
  80088d:	74 ef                	je     80087e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 11             	movzbl (%ecx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008aa:	eb 05                	jmp    8008b1 <strchr+0x10>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0c                	je     8008bc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	40                   	inc    %eax
  8008b1:	8a 10                	mov    (%eax),%dl
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f5                	jne    8008ac <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c7:	eb 05                	jmp    8008ce <strfind+0x10>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 07                	je     8008d4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	40                   	inc    %eax
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f5                	jne    8008c9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 30                	je     800919 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ef:	75 25                	jne    800916 <memset+0x40>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 20                	jne    800916 <memset+0x40>
		c &= 0xFF;
  8008f6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	c1 e3 08             	shl    $0x8,%ebx
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 18             	shl    $0x18,%esi
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 10             	shl    $0x10,%eax
  800908:	09 f0                	or     %esi,%eax
  80090a:	09 d0                	or     %edx,%eax
  80090c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800911:	fc                   	cld    
  800912:	f3 ab                	rep stos %eax,%es:(%edi)
  800914:	eb 03                	jmp    800919 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092e:	39 c6                	cmp    %eax,%esi
  800930:	73 34                	jae    800966 <memmove+0x46>
  800932:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800935:	39 d0                	cmp    %edx,%eax
  800937:	73 2d                	jae    800966 <memmove+0x46>
		s += n;
		d += n;
  800939:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	f6 c2 03             	test   $0x3,%dl
  80093f:	75 1b                	jne    80095c <memmove+0x3c>
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 13                	jne    80095c <memmove+0x3c>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0e                	jne    80095c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 07                	jmp    800963 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	4f                   	dec    %edi
  80095d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800960:	fd                   	std    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800963:	fc                   	cld    
  800964:	eb 20                	jmp    800986 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096c:	75 13                	jne    800981 <memmove+0x61>
  80096e:	a8 03                	test   $0x3,%al
  800970:	75 0f                	jne    800981 <memmove+0x61>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0a                	jne    800981 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800977:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097a:	89 c7                	mov    %eax,%edi
  80097c:	fc                   	cld    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 05                	jmp    800986 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800990:	8b 45 10             	mov    0x10(%ebp),%eax
  800993:	89 44 24 08          	mov    %eax,0x8(%esp)
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	89 04 24             	mov    %eax,(%esp)
  8009a4:	e8 77 ff ff ff       	call   800920 <memmove>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	eb 16                	jmp    8009d7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009c4:	42                   	inc    %edx
  8009c5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009c9:	38 c8                	cmp    %cl,%al
  8009cb:	74 0a                	je     8009d7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009cd:	0f b6 c0             	movzbl %al,%eax
  8009d0:	0f b6 c9             	movzbl %cl,%ecx
  8009d3:	29 c8                	sub    %ecx,%eax
  8009d5:	eb 09                	jmp    8009e0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	75 e6                	jne    8009c1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f3:	eb 05                	jmp    8009fa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	74 05                	je     8009fe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	72 f7                	jb     8009f5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 55 08             	mov    0x8(%ebp),%edx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 01                	jmp    800a0f <strtol+0xf>
		s++;
  800a0e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	8a 02                	mov    (%edx),%al
  800a11:	3c 20                	cmp    $0x20,%al
  800a13:	74 f9                	je     800a0e <strtol+0xe>
  800a15:	3c 09                	cmp    $0x9,%al
  800a17:	74 f5                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a19:	3c 2b                	cmp    $0x2b,%al
  800a1b:	75 08                	jne    800a25 <strtol+0x25>
		s++;
  800a1d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb 13                	jmp    800a38 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	75 0a                	jne    800a33 <strtol+0x33>
		s++, neg = 1;
  800a29:	8d 52 01             	lea    0x1(%edx),%edx
  800a2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a31:	eb 05                	jmp    800a38 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	74 05                	je     800a41 <strtol+0x41>
  800a3c:	83 fb 10             	cmp    $0x10,%ebx
  800a3f:	75 28                	jne    800a69 <strtol+0x69>
  800a41:	8a 02                	mov    (%edx),%al
  800a43:	3c 30                	cmp    $0x30,%al
  800a45:	75 10                	jne    800a57 <strtol+0x57>
  800a47:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4b:	75 0a                	jne    800a57 <strtol+0x57>
		s += 2, base = 16;
  800a4d:	83 c2 02             	add    $0x2,%edx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 12                	jmp    800a69 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 0e                	jne    800a69 <strtol+0x69>
  800a5b:	3c 30                	cmp    $0x30,%al
  800a5d:	75 05                	jne    800a64 <strtol+0x64>
		s++, base = 8;
  800a5f:	42                   	inc    %edx
  800a60:	b3 08                	mov    $0x8,%bl
  800a62:	eb 05                	jmp    800a69 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a64:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	8a 0a                	mov    (%edx),%cl
  800a72:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a75:	80 fb 09             	cmp    $0x9,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x82>
			dig = *s - '0';
  800a7a:	0f be c9             	movsbl %cl,%ecx
  800a7d:	83 e9 30             	sub    $0x30,%ecx
  800a80:	eb 1e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a82:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8a:	0f be c9             	movsbl %cl,%ecx
  800a8d:	83 e9 57             	sub    $0x57,%ecx
  800a90:	eb 0e                	jmp    800aa0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a92:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 12                	ja     800aac <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9a:	0f be c9             	movsbl %cl,%ecx
  800a9d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa0:	39 f1                	cmp    %esi,%ecx
  800aa2:	7d 0c                	jge    800ab0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aa4:	42                   	inc    %edx
  800aa5:	0f af c6             	imul   %esi,%eax
  800aa8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aaa:	eb c4                	jmp    800a70 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aac:	89 c1                	mov    %eax,%ecx
  800aae:	eb 02                	jmp    800ab2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab6:	74 05                	je     800abd <strtol+0xbd>
		*endptr = (char *) s;
  800ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800abd:	85 ff                	test   %edi,%edi
  800abf:	74 04                	je     800ac5 <strtol+0xc5>
  800ac1:	89 c8                	mov    %ecx,%eax
  800ac3:	f7 d8                	neg    %eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    
	...

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
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
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 28                	jle    800b53 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b36:	00 
  800b37:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b46:	00 
  800b47:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800b4e:	e8 89 06 00 00       	call   8011dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	83 c4 2c             	add    $0x2c,%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 28                	jle    800be5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd8:	00 
  800bd9:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800be0:	e8 f7 05 00 00       	call   8011dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be5:	83 c4 2c             	add    $0x2c,%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 28                	jle    800c38 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800c23:	00 
  800c24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2b:	00 
  800c2c:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800c33:	e8 a4 05 00 00       	call   8011dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	83 c4 2c             	add    $0x2c,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 28                	jle    800c8b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c67:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800c86:	e8 51 05 00 00       	call   8011dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8b:	83 c4 2c             	add    $0x2c,%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 28                	jle    800cde <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800cc9:	00 
  800cca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd1:	00 
  800cd2:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800cd9:	e8 fe 04 00 00       	call   8011dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cde:	83 c4 2c             	add    $0x2c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 28                	jle    800d31 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800d2c:	e8 ab 04 00 00       	call   8011dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d31:	83 c4 2c             	add    $0x2c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	be 00 00 00 00       	mov    $0x0,%esi
  800d44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
  800d62:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 cb                	mov    %ecx,%ebx
  800d74:	89 cf                	mov    %ecx,%edi
  800d76:	89 ce                	mov    %ecx,%esi
  800d78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 28                	jle    800da6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d82:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d89:	00 
  800d8a:	c7 44 24 08 a8 17 80 	movl   $0x8017a8,0x8(%esp)
  800d91:	00 
  800d92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d99:	00 
  800d9a:	c7 04 24 c5 17 80 00 	movl   $0x8017c5,(%esp)
  800da1:	e8 36 04 00 00       	call   8011dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da6:	83 c4 2c             	add    $0x2c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    
	...

00800db0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 20             	sub    $0x20,%esp
	void *addr = (void *) utf->utf_fault_va;
  800db8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbb:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) == 0){
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	c1 e8 0c             	shr    $0xc,%eax
  800dc2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc9:	a9 02 08 00 00       	test   $0x802,%eax
  800dce:	75 1c                	jne    800dec <pgfault+0x3c>
            panic("phfault fail at perm of faulting access!\n");
  800dd0:	c7 44 24 08 d4 17 80 	movl   $0x8017d4,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  800de7:	e8 f0 03 00 00       	call   8011dc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t env_id = sys_getenvid();
  800dec:	e8 6a fd ff ff       	call   800b5b <sys_getenvid>
  800df1:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(env_id, (void *)PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
  800df3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e02:	00 
  800e03:	89 04 24             	mov    %eax,(%esp)
  800e06:	e8 8e fd ff ff       	call   800b99 <sys_page_alloc>
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 1c                	jns    800e2b <pgfault+0x7b>
            panic("pafault fail at page_alloc!\n");
  800e0f:	c7 44 24 08 a1 18 80 	movl   $0x8018a1,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  800e26:	e8 b1 03 00 00       	call   8011dc <_panic>
        addr = ROUNDDOWN(addr, PGSIZE);
  800e2b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e31:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e38:	00 
  800e39:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e44:	e8 d7 fa ff ff       	call   800920 <memmove>
        if(sys_page_unmap(env_id, addr) < 0)
  800e49:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4d:	89 1c 24             	mov    %ebx,(%esp)
  800e50:	e8 eb fd ff ff       	call   800c40 <sys_page_unmap>
  800e55:	85 c0                	test   %eax,%eax
  800e57:	79 1c                	jns    800e75 <pgfault+0xc5>
            panic("pafault fail at page_unmap addr!\n");
  800e59:	c7 44 24 08 00 18 80 	movl   $0x801800,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  800e70:	e8 67 03 00 00       	call   8011dc <_panic>
        if(sys_page_map(env_id, PFTEMP, env_id, addr, PTE_P|PTE_U|PTE_W) < 0)
  800e75:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e7c:	00 
  800e7d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e81:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e85:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e8c:	00 
  800e8d:	89 1c 24             	mov    %ebx,(%esp)
  800e90:	e8 58 fd ff ff       	call   800bed <sys_page_map>
  800e95:	85 c0                	test   %eax,%eax
  800e97:	79 1c                	jns    800eb5 <pgfault+0x105>
            panic("page_map fail at page_map!\n");
  800e99:	c7 44 24 08 be 18 80 	movl   $0x8018be,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  800eb0:	e8 27 03 00 00       	call   8011dc <_panic>
        if(sys_page_unmap(env_id, PFTEMP) < 0)
  800eb5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ebc:	00 
  800ebd:	89 1c 24             	mov    %ebx,(%esp)
  800ec0:	e8 7b fd ff ff       	call   800c40 <sys_page_unmap>
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	79 1c                	jns    800ee5 <pgfault+0x135>
            panic("pafault fail at page_unmap PFTEMP!\n");
  800ec9:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  800ee0:	e8 f7 02 00 00       	call   8011dc <_panic>
	//panic("pgfault not implemented");
}
  800ee5:	83 c4 20             	add    $0x20,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        set_pgfault_handler(pgfault);
  800ef5:	c7 04 24 b0 0d 80 00 	movl   $0x800db0,(%esp)
  800efc:	e8 33 03 00 00       	call   801234 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f01:	ba 07 00 00 00       	mov    $0x7,%edx
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	cd 30                	int    $0x30
  800f0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 1c                	jns    800f30 <fork+0x44>
            panic("fork fail at sys_exofork!\n");
  800f14:	c7 44 24 08 da 18 80 	movl   $0x8018da,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  800f2b:	e8 ac 02 00 00       	call   8011dc <_panic>
        else if(env_id == 0){
  800f30:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800f34:	75 25                	jne    800f5b <fork+0x6f>
            thisenv = &envs[ENVX(sys_getenvid())];
  800f36:	e8 20 fc ff ff       	call   800b5b <sys_getenvid>
  800f3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f47:	c1 e0 07             	shl    $0x7,%eax
  800f4a:	29 d0                	sub    %edx,%eax
  800f4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f51:	a3 04 20 80 00       	mov    %eax,0x802004
            return 0;
  800f56:	e9 51 02 00 00       	jmp    8011ac <fork+0x2c0>
        set_pgfault_handler(pgfault);
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
            panic("fork fail at sys_exofork!\n");
        else if(env_id == 0){
  800f5b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
  800f62:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f65:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  800f6c:	a8 01                	test   $0x1,%al
  800f6e:	0f 84 ea 00 00 00    	je     80105e <fork+0x172>
                    for(j = 0; j < NPTENTRIES; j++){
                        pn = PGNUM(PGADDR(i,j,0)); 
  800f74:	c1 e2 16             	shl    $0x16,%edx
  800f77:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f7a:	be 00 00 00 00       	mov    $0x0,%esi
  800f7f:	89 f3                	mov    %esi,%ebx
  800f81:	c1 e3 0c             	shl    $0xc,%ebx
  800f84:	0b 5d e4             	or     -0x1c(%ebp),%ebx
  800f87:	c1 eb 0c             	shr    $0xc,%ebx
                        if(pn == PGNUM(UTOP - PGSIZE))
  800f8a:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  800f90:	0f 84 c8 00 00 00    	je     80105e <fork+0x172>
                            break;
                        if(uvpt[pn] & PTE_P)
  800f96:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f9d:	a8 01                	test   $0x1,%al
  800f9f:	0f 84 ac 00 00 00    	je     801051 <fork+0x165>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
  800fa5:	e8 b1 fb ff ff       	call   800b5b <sys_getenvid>
  800faa:	89 45 e0             	mov    %eax,-0x20(%ebp)
        pte_t pte = uvpt[pn];
  800fad:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
        void *addr = (void *)(pn * PGSIZE);
  800fb4:	89 df                	mov    %ebx,%edi
  800fb6:	c1 e7 0c             	shl    $0xc,%edi
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
  800fb9:	25 02 08 00 00       	and    $0x802,%eax
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
        pte_t pte = uvpt[pn];
        void *addr = (void *)(pn * PGSIZE);
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
  800fbe:	83 f8 01             	cmp    $0x1,%eax
  800fc1:	19 db                	sbb    %ebx,%ebx
  800fc3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800fc9:	81 c3 05 08 00 00    	add    $0x805,%ebx
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
            perm |= PTE_COW;
        if(sys_page_map(srcenv_id, addr, envid, addr, PTE_P|PTE_U|PTE_COW) < 0)
  800fcf:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fd6:	00 
  800fd7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fe6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe9:	89 04 24             	mov    %eax,(%esp)
  800fec:	e8 fc fb ff ff       	call   800bed <sys_page_map>
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	79 1c                	jns    801011 <fork+0x125>
            panic("duppage fail at page map1!\n");
  800ff5:	c7 44 24 08 f5 18 80 	movl   $0x8018f5,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  80100c:	e8 cb 01 00 00       	call   8011dc <_panic>
        if(perm & PTE_COW){
  801011:	f6 c7 08             	test   $0x8,%bh
  801014:	74 3b                	je     801051 <fork+0x165>
            if(sys_page_map(srcenv_id, addr, srcenv_id, addr, perm) < 0)
  801016:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80101a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80101e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801021:	89 44 24 08          	mov    %eax,0x8(%esp)
  801025:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801029:	89 04 24             	mov    %eax,(%esp)
  80102c:	e8 bc fb ff ff       	call   800bed <sys_page_map>
  801031:	85 c0                	test   %eax,%eax
  801033:	79 1c                	jns    801051 <fork+0x165>
                panic("duppage fail at page map2!\n");
  801035:	c7 44 24 08 11 19 80 	movl   $0x801911,0x8(%esp)
  80103c:	00 
  80103d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801044:	00 
  801045:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  80104c:	e8 8b 01 00 00       	call   8011dc <_panic>
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
                    for(j = 0; j < NPTENTRIES; j++){
  801051:	46                   	inc    %esi
  801052:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  801058:	0f 85 21 ff ff ff    	jne    800f7f <fork+0x93>
            thisenv = &envs[ENVX(sys_getenvid())];
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
  80105e:	ff 45 dc             	incl   -0x24(%ebp)
  801061:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  801068:	0f 85 f4 fe ff ff    	jne    800f62 <fork+0x76>
                        if(uvpt[pn] & PTE_P)
                            duppage(env_id, pn);
                    }
                }
            }
            if(sys_page_alloc(env_id,(void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  80106e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80107d:	ee 
  80107e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801081:	89 04 24             	mov    %eax,(%esp)
  801084:	e8 10 fb ff ff       	call   800b99 <sys_page_alloc>
  801089:	85 c0                	test   %eax,%eax
  80108b:	79 1c                	jns    8010a9 <fork+0x1bd>
                panic("fork fail at sys_page_alloc!\n");
  80108d:	c7 44 24 08 2d 19 80 	movl   $0x80192d,0x8(%esp)
  801094:	00 
  801095:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  80109c:	00 
  80109d:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  8010a4:	e8 33 01 00 00       	call   8011dc <_panic>
            if(sys_page_map(env_id, (void *)(UXSTACKTOP - PGSIZE), sys_getenvid(), PFTEMP, PTE_U|PTE_P|PTE_W) < 0)
  8010a9:	e8 ad fa ff ff       	call   800b5b <sys_getenvid>
  8010ae:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  8010bd:	00 
  8010be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010c9:	ee 
  8010ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010cd:	89 04 24             	mov    %eax,(%esp)
  8010d0:	e8 18 fb ff ff       	call   800bed <sys_page_map>
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 1c                	jns    8010f5 <fork+0x209>
                panic("fork fail at sys_page_map!\n");
  8010d9:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  8010f0:	e8 e7 00 00 00       	call   8011dc <_panic>
            memmove((void *)(UXSTACKTOP - PGSIZE),PFTEMP, PGSIZE);
  8010f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010fc:	00 
  8010fd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801104:	00 
  801105:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  80110c:	e8 0f f8 ff ff       	call   800920 <memmove>
            if(sys_page_unmap(sys_getenvid(), PFTEMP) < 0)
  801111:	e8 45 fa ff ff       	call   800b5b <sys_getenvid>
  801116:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80111d:	00 
  80111e:	89 04 24             	mov    %eax,(%esp)
  801121:	e8 1a fb ff ff       	call   800c40 <sys_page_unmap>
  801126:	85 c0                	test   %eax,%eax
  801128:	79 1c                	jns    801146 <fork+0x25a>
                panic("fork fail at sys_page_unmap!\n");
  80112a:	c7 44 24 08 67 19 80 	movl   $0x801967,0x8(%esp)
  801131:	00 
  801132:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801139:	00 
  80113a:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  801141:	e8 96 00 00 00       	call   8011dc <_panic>
            
            extern void _pgfault_upcall(void);
            if(sys_env_set_pgfault_upcall(env_id, _pgfault_upcall) < 0)
  801146:	c7 44 24 04 c0 12 80 	movl   $0x8012c0,0x4(%esp)
  80114d:	00 
  80114e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801151:	89 04 24             	mov    %eax,(%esp)
  801154:	e8 8d fb ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>
  801159:	85 c0                	test   %eax,%eax
  80115b:	79 1c                	jns    801179 <fork+0x28d>
                panic("fork fail at sys_env_set_pgfault_upcall!\n");
  80115d:	c7 44 24 08 48 18 80 	movl   $0x801848,0x8(%esp)
  801164:	00 
  801165:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  80116c:	00 
  80116d:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  801174:	e8 63 00 00 00       	call   8011dc <_panic>
            if(sys_env_set_status(env_id,ENV_RUNNABLE) < 0)
  801179:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801180:	00 
  801181:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801184:	89 04 24             	mov    %eax,(%esp)
  801187:	e8 07 fb ff ff       	call   800c93 <sys_env_set_status>
  80118c:	85 c0                	test   %eax,%eax
  80118e:	79 1c                	jns    8011ac <fork+0x2c0>
                panic("fork fail at sys_env_set_status!\n");
  801190:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  80119f:	00 
  8011a0:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  8011a7:	e8 30 00 00 00       	call   8011dc <_panic>
            return env_id;
        }
}
  8011ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011af:	83 c4 4c             	add    $0x4c,%esp
  8011b2:	5b                   	pop    %ebx
  8011b3:	5e                   	pop    %esi
  8011b4:	5f                   	pop    %edi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011bd:	c7 44 24 08 85 19 80 	movl   $0x801985,0x8(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 96 18 80 00 	movl   $0x801896,(%esp)
  8011d4:	e8 03 00 00 00       	call   8011dc <_panic>
  8011d9:	00 00                	add    %al,(%eax)
	...

008011dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011e7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011ed:	e8 69 f9 ff ff       	call   800b5b <sys_getenvid>
  8011f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801200:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801204:	89 44 24 04          	mov    %eax,0x4(%esp)
  801208:	c7 04 24 9c 19 80 00 	movl   $0x80199c,(%esp)
  80120f:	e8 e8 ef ff ff       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801214:	89 74 24 04          	mov    %esi,0x4(%esp)
  801218:	8b 45 10             	mov    0x10(%ebp),%eax
  80121b:	89 04 24             	mov    %eax,(%esp)
  80121e:	e8 78 ef ff ff       	call   80019b <vcprintf>
	cprintf("\n");
  801223:	c7 04 24 0f 19 80 00 	movl   $0x80190f,(%esp)
  80122a:	e8 cd ef ff ff       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80122f:	cc                   	int3   
  801230:	eb fd                	jmp    80122f <_panic+0x53>
	...

00801234 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80123a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801241:	75 3d                	jne    801280 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  801243:	e8 13 f9 ff ff       	call   800b5b <sys_getenvid>
  801248:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80124f:	00 
  801250:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801257:	ee 
  801258:	89 04 24             	mov    %eax,(%esp)
  80125b:	e8 39 f9 ff ff       	call   800b99 <sys_page_alloc>
  801260:	85 c0                	test   %eax,%eax
  801262:	79 1c                	jns    801280 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  801264:	c7 44 24 08 c0 19 80 	movl   $0x8019c0,0x8(%esp)
  80126b:	00 
  80126c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801273:	00 
  801274:	c7 04 24 18 1a 80 00 	movl   $0x801a18,(%esp)
  80127b:	e8 5c ff ff ff       	call   8011dc <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
  801283:	a3 08 20 80 00       	mov    %eax,0x802008
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  801288:	e8 ce f8 ff ff       	call   800b5b <sys_getenvid>
  80128d:	c7 44 24 04 c0 12 80 	movl   $0x8012c0,0x4(%esp)
  801294:	00 
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	e8 49 fa ff ff       	call   800ce6 <sys_env_set_pgfault_upcall>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	79 1c                	jns    8012bd <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  8012a1:	c7 44 24 08 f0 19 80 	movl   $0x8019f0,0x8(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 18 1a 80 00 	movl   $0x801a18,(%esp)
  8012b8:	e8 1f ff ff ff       	call   8011dc <_panic>
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    
	...

008012c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012c1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012c8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  8012cb:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  8012cd:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  8012d1:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  8012d5:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  8012d6:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  8012d8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  8012dd:	58                   	pop    %eax
        popl %eax
  8012de:	58                   	pop    %eax
        popal
  8012df:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  8012e0:	83 c4 04             	add    $0x4,%esp
        popfl
  8012e3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8012e4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  8012e5:	c3                   	ret    
	...

008012e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8012e8:	55                   	push   %ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	83 ec 10             	sub    $0x10,%esp
  8012ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8012f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8012fe:	89 cd                	mov    %ecx,%ebp
  801300:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801304:	85 c0                	test   %eax,%eax
  801306:	75 2c                	jne    801334 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801308:	39 f9                	cmp    %edi,%ecx
  80130a:	77 68                	ja     801374 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80130c:	85 c9                	test   %ecx,%ecx
  80130e:	75 0b                	jne    80131b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801310:	b8 01 00 00 00       	mov    $0x1,%eax
  801315:	31 d2                	xor    %edx,%edx
  801317:	f7 f1                	div    %ecx
  801319:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	89 f8                	mov    %edi,%eax
  80131f:	f7 f1                	div    %ecx
  801321:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801323:	89 f0                	mov    %esi,%eax
  801325:	f7 f1                	div    %ecx
  801327:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801329:	89 f0                	mov    %esi,%eax
  80132b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801334:	39 f8                	cmp    %edi,%eax
  801336:	77 2c                	ja     801364 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801338:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80133b:	83 f6 1f             	xor    $0x1f,%esi
  80133e:	75 4c                	jne    80138c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801340:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801342:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801347:	72 0a                	jb     801353 <__udivdi3+0x6b>
  801349:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80134d:	0f 87 ad 00 00 00    	ja     801400 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801353:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801358:	89 f0                	mov    %esi,%eax
  80135a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    
  801363:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801364:	31 ff                	xor    %edi,%edi
  801366:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801368:	89 f0                	mov    %esi,%eax
  80136a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    
  801373:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801374:	89 fa                	mov    %edi,%edx
  801376:	89 f0                	mov    %esi,%eax
  801378:	f7 f1                	div    %ecx
  80137a:	89 c6                	mov    %eax,%esi
  80137c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80137e:	89 f0                	mov    %esi,%eax
  801380:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	5e                   	pop    %esi
  801386:	5f                   	pop    %edi
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    
  801389:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80138c:	89 f1                	mov    %esi,%ecx
  80138e:	d3 e0                	shl    %cl,%eax
  801390:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801394:	b8 20 00 00 00       	mov    $0x20,%eax
  801399:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80139b:	89 ea                	mov    %ebp,%edx
  80139d:	88 c1                	mov    %al,%cl
  80139f:	d3 ea                	shr    %cl,%edx
  8013a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013a5:	09 ca                	or     %ecx,%edx
  8013a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8013ab:	89 f1                	mov    %esi,%ecx
  8013ad:	d3 e5                	shl    %cl,%ebp
  8013af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8013b3:	89 fd                	mov    %edi,%ebp
  8013b5:	88 c1                	mov    %al,%cl
  8013b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8013b9:	89 fa                	mov    %edi,%edx
  8013bb:	89 f1                	mov    %esi,%ecx
  8013bd:	d3 e2                	shl    %cl,%edx
  8013bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c3:	88 c1                	mov    %al,%cl
  8013c5:	d3 ef                	shr    %cl,%edi
  8013c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	89 ea                	mov    %ebp,%edx
  8013cd:	f7 74 24 08          	divl   0x8(%esp)
  8013d1:	89 d1                	mov    %edx,%ecx
  8013d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8013d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013d9:	39 d1                	cmp    %edx,%ecx
  8013db:	72 17                	jb     8013f4 <__udivdi3+0x10c>
  8013dd:	74 09                	je     8013e8 <__udivdi3+0x100>
  8013df:	89 fe                	mov    %edi,%esi
  8013e1:	31 ff                	xor    %edi,%edi
  8013e3:	e9 41 ff ff ff       	jmp    801329 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8013e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013f0:	39 c2                	cmp    %eax,%edx
  8013f2:	73 eb                	jae    8013df <__udivdi3+0xf7>
		{
		  q0--;
  8013f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8013f7:	31 ff                	xor    %edi,%edi
  8013f9:	e9 2b ff ff ff       	jmp    801329 <__udivdi3+0x41>
  8013fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801400:	31 f6                	xor    %esi,%esi
  801402:	e9 22 ff ff ff       	jmp    801329 <__udivdi3+0x41>
	...

00801408 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801408:	55                   	push   %ebp
  801409:	57                   	push   %edi
  80140a:	56                   	push   %esi
  80140b:	83 ec 20             	sub    $0x20,%esp
  80140e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801412:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801416:	89 44 24 14          	mov    %eax,0x14(%esp)
  80141a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80141e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801422:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801426:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801428:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80142a:	85 ed                	test   %ebp,%ebp
  80142c:	75 16                	jne    801444 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80142e:	39 f1                	cmp    %esi,%ecx
  801430:	0f 86 a6 00 00 00    	jbe    8014dc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801436:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801438:	89 d0                	mov    %edx,%eax
  80143a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80143c:	83 c4 20             	add    $0x20,%esp
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    
  801443:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801444:	39 f5                	cmp    %esi,%ebp
  801446:	0f 87 ac 00 00 00    	ja     8014f8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80144c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80144f:	83 f0 1f             	xor    $0x1f,%eax
  801452:	89 44 24 10          	mov    %eax,0x10(%esp)
  801456:	0f 84 a8 00 00 00    	je     801504 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80145c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801460:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801462:	bf 20 00 00 00       	mov    $0x20,%edi
  801467:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80146b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80146f:	89 f9                	mov    %edi,%ecx
  801471:	d3 e8                	shr    %cl,%eax
  801473:	09 e8                	or     %ebp,%eax
  801475:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801479:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80147d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801481:	d3 e0                	shl    %cl,%eax
  801483:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801487:	89 f2                	mov    %esi,%edx
  801489:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80148b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80148f:	d3 e0                	shl    %cl,%eax
  801491:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801495:	8b 44 24 14          	mov    0x14(%esp),%eax
  801499:	89 f9                	mov    %edi,%ecx
  80149b:	d3 e8                	shr    %cl,%eax
  80149d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80149f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014a1:	89 f2                	mov    %esi,%edx
  8014a3:	f7 74 24 18          	divl   0x18(%esp)
  8014a7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8014a9:	f7 64 24 0c          	mull   0xc(%esp)
  8014ad:	89 c5                	mov    %eax,%ebp
  8014af:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	72 67                	jb     80151c <__umoddi3+0x114>
  8014b5:	74 75                	je     80152c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8014b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014bb:	29 e8                	sub    %ebp,%eax
  8014bd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8014bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014c3:	d3 e8                	shr    %cl,%eax
  8014c5:	89 f2                	mov    %esi,%edx
  8014c7:	89 f9                	mov    %edi,%ecx
  8014c9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8014cb:	09 d0                	or     %edx,%eax
  8014cd:	89 f2                	mov    %esi,%edx
  8014cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014d3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014d5:	83 c4 20             	add    $0x20,%esp
  8014d8:	5e                   	pop    %esi
  8014d9:	5f                   	pop    %edi
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8014dc:	85 c9                	test   %ecx,%ecx
  8014de:	75 0b                	jne    8014eb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8014e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e5:	31 d2                	xor    %edx,%edx
  8014e7:	f7 f1                	div    %ecx
  8014e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8014eb:	89 f0                	mov    %esi,%eax
  8014ed:	31 d2                	xor    %edx,%edx
  8014ef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014f1:	89 f8                	mov    %edi,%eax
  8014f3:	e9 3e ff ff ff       	jmp    801436 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8014f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014fa:	83 c4 20             	add    $0x20,%esp
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
  801501:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801504:	39 f5                	cmp    %esi,%ebp
  801506:	72 04                	jb     80150c <__umoddi3+0x104>
  801508:	39 f9                	cmp    %edi,%ecx
  80150a:	77 06                	ja     801512 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80150c:	89 f2                	mov    %esi,%edx
  80150e:	29 cf                	sub    %ecx,%edi
  801510:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801512:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801514:	83 c4 20             	add    $0x20,%esp
  801517:	5e                   	pop    %esi
  801518:	5f                   	pop    %edi
  801519:	5d                   	pop    %ebp
  80151a:	c3                   	ret    
  80151b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80151c:	89 d1                	mov    %edx,%ecx
  80151e:	89 c5                	mov    %eax,%ebp
  801520:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801524:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801528:	eb 8d                	jmp    8014b7 <__umoddi3+0xaf>
  80152a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80152c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801530:	72 ea                	jb     80151c <__umoddi3+0x114>
  801532:	89 f1                	mov    %esi,%ecx
  801534:	eb 81                	jmp    8014b7 <__umoddi3+0xaf>
