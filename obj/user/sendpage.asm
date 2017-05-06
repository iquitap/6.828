
obj/user/sendpage：     文件格式 elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 99 0f 00 00       	call   800fd8 <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 63 12 00 00       	call   8012c8 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 40 17 80 00 	movl   $0x801740,(%esp)
  80007b:	e8 68 02 00 00       	call   8002e8 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 d3 07 00 00       	call   800860 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 b5 08 00 00       	call   80095b <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  8000b1:	e8 32 02 00 00       	call   8002e8 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 9d 07 00 00       	call   800860 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 99 09 00 00       	call   800a76 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 2f 12 00 00       	call   80132f <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 60 0b 00 00       	call   800c85 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 20 80 00       	mov    0x802004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 2e 07 00 00       	call   800860 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 20 80 00       	mov    0x802004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 2a 09 00 00       	call   800a76 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 c0 11 00 00       	call   80132f <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 3e 11 00 00       	call   8012c8 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 40 17 80 00 	movl   $0x801740,(%esp)
  8001a0:	e8 43 01 00 00       	call   8002e8 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 ae 06 00 00       	call   800860 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 90 07 00 00       	call   80095b <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8001d6:	e8 0d 01 00 00       	call   8002e8 <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	00 00                	add    %al,(%eax)
	...

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  8001ee:	e8 54 0a 00 00       	call   800c47 <sys_getenvid>
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 0c 20 80 00       	mov    %eax,0x80200c

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x39>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021d:	89 34 24             	mov    %esi,(%esp)
  800220:	e8 0f fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 af 09 00 00       	call   800bf5 <sys_env_destroy>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	53                   	push   %ebx
  80024c:	83 ec 14             	sub    $0x14,%esp
  80024f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800252:	8b 03                	mov    (%ebx),%eax
  800254:	8b 55 08             	mov    0x8(%ebp),%edx
  800257:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80025b:	40                   	inc    %eax
  80025c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80025e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800263:	75 19                	jne    80027e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800265:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80026c:	00 
  80026d:	8d 43 08             	lea    0x8(%ebx),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 40 09 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  800278:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027e:	ff 43 04             	incl   0x4(%ebx)
}
  800281:	83 c4 14             	add    $0x14,%esp
  800284:	5b                   	pop    %ebx
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800290:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800297:	00 00 00 
	b.cnt = 0;
  80029a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	c7 04 24 48 02 80 00 	movl   $0x800248,(%esp)
  8002c3:	e8 82 01 00 00       	call   80044a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 d8 08 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  8002e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 87 ff ff ff       	call   800287 <vcprintf>
	va_end(ap);

	return cnt;
}
  800300:	c9                   	leave  
  800301:	c3                   	ret    
	...

00800304 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 3c             	sub    $0x3c,%esp
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	89 d7                	mov    %edx,%edi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800321:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800324:	85 c0                	test   %eax,%eax
  800326:	75 08                	jne    800330 <printnum+0x2c>
  800328:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80032e:	77 57                	ja     800387 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800330:	89 74 24 10          	mov    %esi,0x10(%esp)
  800334:	4b                   	dec    %ebx
  800335:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800344:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034f:	00 
  800350:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	e8 86 11 00 00       	call   8014e8 <__udivdi3>
  800362:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800366:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800371:	89 fa                	mov    %edi,%edx
  800373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800376:	e8 89 ff ff ff       	call   800304 <printnum>
  80037b:	eb 0f                	jmp    80038c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	89 34 24             	mov    %esi,(%esp)
  800384:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	4b                   	dec    %ebx
  800388:	85 db                	test   %ebx,%ebx
  80038a:	7f f1                	jg     80037d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 10             	mov    0x10(%ebp),%eax
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a2:	00 
  8003a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	e8 53 12 00 00       	call   801608 <__umoddi3>
  8003b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b9:	0f be 80 ec 17 80 00 	movsbl 0x8017ec(%eax),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003c6:	83 c4 3c             	add    $0x3c,%esp
  8003c9:	5b                   	pop    %ebx
  8003ca:	5e                   	pop    %esi
  8003cb:	5f                   	pop    %edi
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d1:	83 fa 01             	cmp    $0x1,%edx
  8003d4:	7e 0e                	jle    8003e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003db:	89 08                	mov    %ecx,(%eax)
  8003dd:	8b 02                	mov    (%edx),%eax
  8003df:	8b 52 04             	mov    0x4(%edx),%edx
  8003e2:	eb 22                	jmp    800406 <getuint+0x38>
	else if (lflag)
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	74 10                	je     8003f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	eb 0e                	jmp    800406 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 02                	mov    (%edx),%eax
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800411:	8b 10                	mov    (%eax),%edx
  800413:	3b 50 04             	cmp    0x4(%eax),%edx
  800416:	73 08                	jae    800420 <sprintputch+0x18>
		*b->buf++ = ch;
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	88 0a                	mov    %cl,(%edx)
  80041d:	42                   	inc    %edx
  80041e:	89 10                	mov    %edx,(%eax)
}
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	8b 45 10             	mov    0x10(%ebp),%eax
  800432:	89 44 24 08          	mov    %eax,0x8(%esp)
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 02 00 00 00       	call   80044a <vprintfmt>
	va_end(ap);
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 4c             	sub    $0x4c,%esp
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	8b 75 10             	mov    0x10(%ebp),%esi
  800459:	eb 12                	jmp    80046d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 84 6b 03 00 00    	je     8007ce <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046d:	0f b6 06             	movzbl (%esi),%eax
  800470:	46                   	inc    %esi
  800471:	83 f8 25             	cmp    $0x25,%eax
  800474:	75 e5                	jne    80045b <vprintfmt+0x11>
  800476:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80047a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800481:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800486:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	eb 26                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800497:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80049b:	eb 1d                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004a4:	eb 14                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b0:	eb 08                	jmp    8004ba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	0f b6 06             	movzbl (%esi),%eax
  8004bd:	8d 56 01             	lea    0x1(%esi),%edx
  8004c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c3:	8a 16                	mov    (%esi),%dl
  8004c5:	83 ea 23             	sub    $0x23,%edx
  8004c8:	80 fa 55             	cmp    $0x55,%dl
  8004cb:	0f 87 e1 02 00 00    	ja     8007b2 <vprintfmt+0x368>
  8004d1:	0f b6 d2             	movzbl %dl,%edx
  8004d4:	ff 24 95 c0 18 80 00 	jmp    *0x8018c0(,%edx,4)
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004e6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f0:	83 fa 09             	cmp    $0x9,%edx
  8004f3:	77 2a                	ja     80051f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f6:	eb eb                	jmp    8004e3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800506:	eb 17                	jmp    80051f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050c:	78 98                	js     8004a6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800511:	eb a7                	jmp    8004ba <vprintfmt+0x70>
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80051d:	eb 9b                	jmp    8004ba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80051f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800523:	79 95                	jns    8004ba <vprintfmt+0x70>
  800525:	eb 8b                	jmp    8004b2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800527:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80052b:	eb 8d                	jmp    8004ba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 23 ff ff ff       	jmp    80046d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	85 c0                	test   %eax,%eax
  800557:	79 02                	jns    80055b <vprintfmt+0x111>
  800559:	f7 d8                	neg    %eax
  80055b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055d:	83 f8 09             	cmp    $0x9,%eax
  800560:	7f 0b                	jg     80056d <vprintfmt+0x123>
  800562:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  800569:	85 c0                	test   %eax,%eax
  80056b:	75 23                	jne    800590 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80056d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800571:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800578:	00 
  800579:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 9a fe ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80058b:	e9 dd fe ff ff       	jmp    80046d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800590:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800594:	c7 44 24 08 0d 18 80 	movl   $0x80180d,0x8(%esp)
  80059b:	00 
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a3:	89 14 24             	mov    %edx,(%esp)
  8005a6:	e8 77 fe ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ba fe ff ff       	jmp    80046d <vprintfmt+0x23>
  8005b3:	89 f9                	mov    %edi,%ecx
  8005b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 30                	mov    (%eax),%esi
  8005c6:	85 f6                	test   %esi,%esi
  8005c8:	75 05                	jne    8005cf <vprintfmt+0x185>
				p = "(null)";
  8005ca:	be fd 17 80 00       	mov    $0x8017fd,%esi
			if (width > 0 && padc != '-')
  8005cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d3:	0f 8e 84 00 00 00    	jle    80065d <vprintfmt+0x213>
  8005d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005dd:	74 7e                	je     80065d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e3:	89 34 24             	mov    %esi,(%esp)
  8005e6:	e8 8b 02 00 00       	call   800876 <strnlen>
  8005eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005f3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	89 d3                	mov    %edx,%ebx
  800601:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	eb 0b                	jmp    800610 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	89 3c 24             	mov    %edi,(%esp)
  80060c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	4b                   	dec    %ebx
  800610:	85 db                	test   %ebx,%ebx
  800612:	7f f1                	jg     800605 <vprintfmt+0x1bb>
  800614:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800617:	89 f3                	mov    %esi,%ebx
  800619:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80061c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 05                	jns    800628 <vprintfmt+0x1de>
  800623:	b8 00 00 00 00       	mov    $0x0,%eax
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	29 c2                	sub    %eax,%edx
  80062d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800630:	eb 2b                	jmp    80065d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800632:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800636:	74 18                	je     800650 <vprintfmt+0x206>
  800638:	8d 50 e0             	lea    -0x20(%eax),%edx
  80063b:	83 fa 5e             	cmp    $0x5e,%edx
  80063e:	76 10                	jbe    800650 <vprintfmt+0x206>
					putch('?', putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
  80064e:	eb 0a                	jmp    80065a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	ff 4d e4             	decl   -0x1c(%ebp)
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	46                   	inc    %esi
  800661:	85 c0                	test   %eax,%eax
  800663:	74 21                	je     800686 <vprintfmt+0x23c>
  800665:	85 ff                	test   %edi,%edi
  800667:	78 c9                	js     800632 <vprintfmt+0x1e8>
  800669:	4f                   	dec    %edi
  80066a:	79 c6                	jns    800632 <vprintfmt+0x1e8>
  80066c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066f:	89 de                	mov    %ebx,%esi
  800671:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800674:	eb 18                	jmp    80068e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800676:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800681:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800683:	4b                   	dec    %ebx
  800684:	eb 08                	jmp    80068e <vprintfmt+0x244>
  800686:	8b 7d 08             	mov    0x8(%ebp),%edi
  800689:	89 de                	mov    %ebx,%esi
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80068e:	85 db                	test   %ebx,%ebx
  800690:	7f e4                	jg     800676 <vprintfmt+0x22c>
  800692:	89 7d 08             	mov    %edi,0x8(%ebp)
  800695:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80069a:	e9 ce fd ff ff       	jmp    80046d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7e 10                	jle    8006b4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 08             	lea    0x8(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 30                	mov    (%eax),%esi
  8006af:	8b 78 04             	mov    0x4(%eax),%edi
  8006b2:	eb 26                	jmp    8006da <vprintfmt+0x290>
	else if (lflag)
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	74 12                	je     8006ca <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 30                	mov    (%eax),%esi
  8006c3:	89 f7                	mov    %esi,%edi
  8006c5:	c1 ff 1f             	sar    $0x1f,%edi
  8006c8:	eb 10                	jmp    8006da <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	89 f7                	mov    %esi,%edi
  8006d7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006da:	85 ff                	test   %edi,%edi
  8006dc:	78 0a                	js     8006e8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e3:	e9 8c 00 00 00       	jmp    800774 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f6:	f7 de                	neg    %esi
  8006f8:	83 d7 00             	adc    $0x0,%edi
  8006fb:	f7 df                	neg    %edi
			}
			base = 10;
  8006fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800702:	eb 70                	jmp    800774 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	89 ca                	mov    %ecx,%edx
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 c0 fc ff ff       	call   8003ce <getuint>
  80070e:	89 c6                	mov    %eax,%esi
  800710:	89 d7                	mov    %edx,%edi
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800717:	eb 5b                	jmp    800774 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  800719:	89 ca                	mov    %ecx,%edx
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 ab fc ff ff       	call   8003ce <getuint>
  800723:	89 c6                	mov    %eax,%esi
  800725:	89 d7                	mov    %edx,%edi
                        base = 8;
  800727:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  80072c:	eb 46                	jmp    800774 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  80072e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800732:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800739:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800747:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 50 04             	lea    0x4(%eax),%edx
  800750:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800753:	8b 30                	mov    (%eax),%esi
  800755:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075f:	eb 13                	jmp    800774 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800761:	89 ca                	mov    %ecx,%edx
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 63 fc ff ff       	call   8003ce <getuint>
  80076b:	89 c6                	mov    %eax,%esi
  80076d:	89 d7                	mov    %edx,%edi
			base = 16;
  80076f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800774:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800778:	89 54 24 10          	mov    %edx,0x10(%esp)
  80077c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80077f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800783:	89 44 24 08          	mov    %eax,0x8(%esp)
  800787:	89 34 24             	mov    %esi,(%esp)
  80078a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078e:	89 da                	mov    %ebx,%edx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	e8 6c fb ff ff       	call   800304 <printnum>
			break;
  800798:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80079b:	e9 cd fc ff ff       	jmp    80046d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 bb fc ff ff       	jmp    80046d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007bd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c0:	eb 01                	jmp    8007c3 <vprintfmt+0x379>
  8007c2:	4e                   	dec    %esi
  8007c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c7:	75 f9                	jne    8007c2 <vprintfmt+0x378>
  8007c9:	e9 9f fc ff ff       	jmp    80046d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007ce:	83 c4 4c             	add    $0x4c,%esp
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	5f                   	pop    %edi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 28             	sub    $0x28,%esp
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	74 30                	je     800827 <vsnprintf+0x51>
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	7e 33                	jle    80082e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
  800805:	89 44 24 08          	mov    %eax,0x8(%esp)
  800809:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	c7 04 24 08 04 80 00 	movl   $0x800408,(%esp)
  800817:	e8 2e fc ff ff       	call   80044a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800825:	eb 0c                	jmp    800833 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082c:	eb 05                	jmp    800833 <vsnprintf+0x5d>
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 7b ff ff ff       	call   8007d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    
  80085d:	00 00                	add    %al,(%eax)
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 01                	jmp    80086e <strlen+0xe>
		n++;
  80086d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800872:	75 f9                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb 01                	jmp    800887 <strnlen+0x11>
		n++;
  800886:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800887:	39 d0                	cmp    %edx,%eax
  800889:	74 06                	je     800891 <strnlen+0x1b>
  80088b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088f:	75 f5                	jne    800886 <strnlen+0x10>
		n++;
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008a5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a8:	42                   	inc    %edx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	75 f5                	jne    8008a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ba:	89 1c 24             	mov    %ebx,(%esp)
  8008bd:	e8 9e ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c9:	01 d8                	add    %ebx,%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 c0 ff ff ff       	call   800893 <strcpy>
	return dst;
}
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	83 c4 08             	add    $0x8,%esp
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ee:	eb 0c                	jmp    8008fc <strncpy+0x21>
		*dst++ = *src;
  8008f0:	8a 1a                	mov    (%edx),%bl
  8008f2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	41                   	inc    %ecx
  8008fc:	39 f1                	cmp    %esi,%ecx
  8008fe:	75 f0                	jne    8008f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800912:	85 d2                	test   %edx,%edx
  800914:	75 0a                	jne    800920 <strlcpy+0x1c>
  800916:	89 f0                	mov    %esi,%eax
  800918:	eb 1a                	jmp    800934 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091a:	88 18                	mov    %bl,(%eax)
  80091c:	40                   	inc    %eax
  80091d:	41                   	inc    %ecx
  80091e:	eb 02                	jmp    800922 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800920:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800922:	4a                   	dec    %edx
  800923:	74 0a                	je     80092f <strlcpy+0x2b>
  800925:	8a 19                	mov    (%ecx),%bl
  800927:	84 db                	test   %bl,%bl
  800929:	75 ef                	jne    80091a <strlcpy+0x16>
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	eb 02                	jmp    800931 <strlcpy+0x2d>
  80092f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 02                	jmp    800947 <strcmp+0xd>
		p++, q++;
  800945:	41                   	inc    %ecx
  800946:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800947:	8a 01                	mov    (%ecx),%al
  800949:	84 c0                	test   %al,%al
  80094b:	74 04                	je     800951 <strcmp+0x17>
  80094d:	3a 02                	cmp    (%edx),%al
  80094f:	74 f4                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800965:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800968:	eb 03                	jmp    80096d <strncmp+0x12>
		n--, p++, q++;
  80096a:	4a                   	dec    %edx
  80096b:	40                   	inc    %eax
  80096c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 14                	je     800985 <strncmp+0x2a>
  800971:	8a 18                	mov    (%eax),%bl
  800973:	84 db                	test   %bl,%bl
  800975:	74 04                	je     80097b <strncmp+0x20>
  800977:	3a 19                	cmp    (%ecx),%bl
  800979:	74 ef                	je     80096a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 00             	movzbl (%eax),%eax
  80097e:	0f b6 11             	movzbl (%ecx),%edx
  800981:	29 d0                	sub    %edx,%eax
  800983:	eb 05                	jmp    80098a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098a:	5b                   	pop    %ebx
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800996:	eb 05                	jmp    80099d <strchr+0x10>
		if (*s == c)
  800998:	38 ca                	cmp    %cl,%dl
  80099a:	74 0c                	je     8009a8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099c:	40                   	inc    %eax
  80099d:	8a 10                	mov    (%eax),%dl
  80099f:	84 d2                	test   %dl,%dl
  8009a1:	75 f5                	jne    800998 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009b3:	eb 05                	jmp    8009ba <strfind+0x10>
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 07                	je     8009c0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b9:	40                   	inc    %eax
  8009ba:	8a 10                	mov    (%eax),%dl
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	75 f5                	jne    8009b5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d1:	85 c9                	test   %ecx,%ecx
  8009d3:	74 30                	je     800a05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009db:	75 25                	jne    800a02 <memset+0x40>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 20                	jne    800a02 <memset+0x40>
		c &= 0xFF;
  8009e2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e5:	89 d3                	mov    %edx,%ebx
  8009e7:	c1 e3 08             	shl    $0x8,%ebx
  8009ea:	89 d6                	mov    %edx,%esi
  8009ec:	c1 e6 18             	shl    $0x18,%esi
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	c1 e0 10             	shl    $0x10,%eax
  8009f4:	09 f0                	or     %esi,%eax
  8009f6:	09 d0                	or     %edx,%eax
  8009f8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009fd:	fc                   	cld    
  8009fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800a00:	eb 03                	jmp    800a05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a02:	fc                   	cld    
  800a03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1a:	39 c6                	cmp    %eax,%esi
  800a1c:	73 34                	jae    800a52 <memmove+0x46>
  800a1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a21:	39 d0                	cmp    %edx,%eax
  800a23:	73 2d                	jae    800a52 <memmove+0x46>
		s += n;
		d += n;
  800a25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	f6 c2 03             	test   $0x3,%dl
  800a2b:	75 1b                	jne    800a48 <memmove+0x3c>
  800a2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a33:	75 13                	jne    800a48 <memmove+0x3c>
  800a35:	f6 c1 03             	test   $0x3,%cl
  800a38:	75 0e                	jne    800a48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a3a:	83 ef 04             	sub    $0x4,%edi
  800a3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a43:	fd                   	std    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb 07                	jmp    800a4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a48:	4f                   	dec    %edi
  800a49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4c:	fd                   	std    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4f:	fc                   	cld    
  800a50:	eb 20                	jmp    800a72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a58:	75 13                	jne    800a6d <memmove+0x61>
  800a5a:	a8 03                	test   $0x3,%al
  800a5c:	75 0f                	jne    800a6d <memmove+0x61>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 0a                	jne    800a6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a66:	89 c7                	mov    %eax,%edi
  800a68:	fc                   	cld    
  800a69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6b:	eb 05                	jmp    800a72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 77 ff ff ff       	call   800a0c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aab:	eb 16                	jmp    800ac3 <memcmp+0x2c>
		if (*s1 != *s2)
  800aad:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ab0:	42                   	inc    %edx
  800ab1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ab5:	38 c8                	cmp    %cl,%al
  800ab7:	74 0a                	je     800ac3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 c9             	movzbl %cl,%ecx
  800abf:	29 c8                	sub    %ecx,%eax
  800ac1:	eb 09                	jmp    800acc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac3:	39 da                	cmp    %ebx,%edx
  800ac5:	75 e6                	jne    800aad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800adf:	eb 05                	jmp    800ae6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae1:	38 08                	cmp    %cl,(%eax)
  800ae3:	74 05                	je     800aea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae5:	40                   	inc    %eax
  800ae6:	39 d0                	cmp    %edx,%eax
  800ae8:	72 f7                	jb     800ae1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	eb 01                	jmp    800afb <strtol+0xf>
		s++;
  800afa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afb:	8a 02                	mov    (%edx),%al
  800afd:	3c 20                	cmp    $0x20,%al
  800aff:	74 f9                	je     800afa <strtol+0xe>
  800b01:	3c 09                	cmp    $0x9,%al
  800b03:	74 f5                	je     800afa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b05:	3c 2b                	cmp    $0x2b,%al
  800b07:	75 08                	jne    800b11 <strtol+0x25>
		s++;
  800b09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0f:	eb 13                	jmp    800b24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b11:	3c 2d                	cmp    $0x2d,%al
  800b13:	75 0a                	jne    800b1f <strtol+0x33>
		s++, neg = 1;
  800b15:	8d 52 01             	lea    0x1(%edx),%edx
  800b18:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1d:	eb 05                	jmp    800b24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 05                	je     800b2d <strtol+0x41>
  800b28:	83 fb 10             	cmp    $0x10,%ebx
  800b2b:	75 28                	jne    800b55 <strtol+0x69>
  800b2d:	8a 02                	mov    (%edx),%al
  800b2f:	3c 30                	cmp    $0x30,%al
  800b31:	75 10                	jne    800b43 <strtol+0x57>
  800b33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b37:	75 0a                	jne    800b43 <strtol+0x57>
		s += 2, base = 16;
  800b39:	83 c2 02             	add    $0x2,%edx
  800b3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b41:	eb 12                	jmp    800b55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b43:	85 db                	test   %ebx,%ebx
  800b45:	75 0e                	jne    800b55 <strtol+0x69>
  800b47:	3c 30                	cmp    $0x30,%al
  800b49:	75 05                	jne    800b50 <strtol+0x64>
		s++, base = 8;
  800b4b:	42                   	inc    %edx
  800b4c:	b3 08                	mov    $0x8,%bl
  800b4e:	eb 05                	jmp    800b55 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b50:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5c:	8a 0a                	mov    (%edx),%cl
  800b5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b61:	80 fb 09             	cmp    $0x9,%bl
  800b64:	77 08                	ja     800b6e <strtol+0x82>
			dig = *s - '0';
  800b66:	0f be c9             	movsbl %cl,%ecx
  800b69:	83 e9 30             	sub    $0x30,%ecx
  800b6c:	eb 1e                	jmp    800b8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b71:	80 fb 19             	cmp    $0x19,%bl
  800b74:	77 08                	ja     800b7e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b76:	0f be c9             	movsbl %cl,%ecx
  800b79:	83 e9 57             	sub    $0x57,%ecx
  800b7c:	eb 0e                	jmp    800b8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 12                	ja     800b98 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b86:	0f be c9             	movsbl %cl,%ecx
  800b89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b8c:	39 f1                	cmp    %esi,%ecx
  800b8e:	7d 0c                	jge    800b9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b90:	42                   	inc    %edx
  800b91:	0f af c6             	imul   %esi,%eax
  800b94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b96:	eb c4                	jmp    800b5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b98:	89 c1                	mov    %eax,%ecx
  800b9a:	eb 02                	jmp    800b9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba2:	74 05                	je     800ba9 <strtol+0xbd>
		*endptr = (char *) s;
  800ba4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba9:	85 ff                	test   %edi,%edi
  800bab:	74 04                	je     800bb1 <strtol+0xc5>
  800bad:	89 c8                	mov    %ecx,%eax
  800baf:	f7 d8                	neg    %eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
	...

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 c3                	mov    %eax,%ebx
  800bcb:	89 c7                	mov    %eax,%edi
  800bcd:	89 c6                	mov    %eax,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	b8 03 00 00 00       	mov    $0x3,%eax
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 cb                	mov    %ecx,%ebx
  800c0d:	89 cf                	mov    %ecx,%edi
  800c0f:	89 ce                	mov    %ecx,%esi
  800c11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7e 28                	jle    800c3f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c22:	00 
  800c23:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c32:	00 
  800c33:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800c3a:	e8 9d 07 00 00       	call   8013dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3f:	83 c4 2c             	add    $0x2c,%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 02 00 00 00       	mov    $0x2,%eax
  800c57:	89 d1                	mov    %edx,%ecx
  800c59:	89 d3                	mov    %edx,%ebx
  800c5b:	89 d7                	mov    %edx,%edi
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_yield>:

void
sys_yield(void)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c76:	89 d1                	mov    %edx,%ecx
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	89 d7                	mov    %edx,%edi
  800c7c:	89 d6                	mov    %edx,%esi
  800c7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 04 00 00 00       	mov    $0x4,%eax
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 f7                	mov    %esi,%edi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 28                	jle    800cd1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc4:	00 
  800cc5:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800ccc:	e8 0b 07 00 00       	call   8013dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd1:	83 c4 2c             	add    $0x2c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 28                	jle    800d24 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d00:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d07:	00 
  800d08:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800d1f:	e8 b8 06 00 00       	call   8013dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d24:	83 c4 2c             	add    $0x2c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 28                	jle    800d77 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d53:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800d62:	00 
  800d63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6a:	00 
  800d6b:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800d72:	e8 65 06 00 00       	call   8013dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d77:	83 c4 2c             	add    $0x2c,%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 28                	jle    800dca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dad:	00 
  800dae:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800db5:	00 
  800db6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbd:	00 
  800dbe:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800dc5:	e8 12 06 00 00       	call   8013dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dca:	83 c4 2c             	add    $0x2c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de0:	b8 09 00 00 00       	mov    $0x9,%eax
  800de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	89 df                	mov    %ebx,%edi
  800ded:	89 de                	mov    %ebx,%esi
  800def:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 28                	jle    800e1d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e00:	00 
  800e01:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800e18:	e8 bf 05 00 00       	call   8013dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1d:	83 c4 2c             	add    $0x2c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	be 00 00 00 00       	mov    $0x0,%esi
  800e30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e56:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	89 cb                	mov    %ecx,%ebx
  800e60:	89 cf                	mov    %ecx,%edi
  800e62:	89 ce                	mov    %ecx,%esi
  800e64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 48 1a 80 	movl   $0x801a48,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 65 1a 80 00 	movl   $0x801a65,(%esp)
  800e8d:	e8 4a 05 00 00       	call   8013dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    
	...

00800e9c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 20             	sub    $0x20,%esp
	void *addr = (void *) utf->utf_fault_va;
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea7:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) == 0){
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	c1 e8 0c             	shr    $0xc,%eax
  800eae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb5:	a9 02 08 00 00       	test   $0x802,%eax
  800eba:	75 1c                	jne    800ed8 <pgfault+0x3c>
            panic("phfault fail at perm of faulting access!\n");
  800ebc:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  800ecb:	00 
  800ecc:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  800ed3:	e8 04 05 00 00       	call   8013dc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t env_id = sys_getenvid();
  800ed8:	e8 6a fd ff ff       	call   800c47 <sys_getenvid>
  800edd:	89 c3                	mov    %eax,%ebx
        if(sys_page_alloc(env_id, (void *)PFTEMP, PTE_P | PTE_U | PTE_W) < 0)
  800edf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eee:	00 
  800eef:	89 04 24             	mov    %eax,(%esp)
  800ef2:	e8 8e fd ff ff       	call   800c85 <sys_page_alloc>
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	79 1c                	jns    800f17 <pgfault+0x7b>
            panic("pafault fail at page_alloc!\n");
  800efb:	c7 44 24 08 41 1b 80 	movl   $0x801b41,0x8(%esp)
  800f02:	00 
  800f03:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800f0a:	00 
  800f0b:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  800f12:	e8 c5 04 00 00       	call   8013dc <_panic>
        addr = ROUNDDOWN(addr, PGSIZE);
  800f17:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f1d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f24:	00 
  800f25:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f29:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f30:	e8 d7 fa ff ff       	call   800a0c <memmove>
        if(sys_page_unmap(env_id, addr) < 0)
  800f35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f39:	89 1c 24             	mov    %ebx,(%esp)
  800f3c:	e8 eb fd ff ff       	call   800d2c <sys_page_unmap>
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 1c                	jns    800f61 <pgfault+0xc5>
            panic("pafault fail at page_unmap addr!\n");
  800f45:	c7 44 24 08 a0 1a 80 	movl   $0x801aa0,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  800f5c:	e8 7b 04 00 00       	call   8013dc <_panic>
        if(sys_page_map(env_id, PFTEMP, env_id, addr, PTE_P|PTE_U|PTE_W) < 0)
  800f61:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f68:	00 
  800f69:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f6d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f71:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f78:	00 
  800f79:	89 1c 24             	mov    %ebx,(%esp)
  800f7c:	e8 58 fd ff ff       	call   800cd9 <sys_page_map>
  800f81:	85 c0                	test   %eax,%eax
  800f83:	79 1c                	jns    800fa1 <pgfault+0x105>
            panic("page_map fail at page_map!\n");
  800f85:	c7 44 24 08 5e 1b 80 	movl   $0x801b5e,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  800f9c:	e8 3b 04 00 00       	call   8013dc <_panic>
        if(sys_page_unmap(env_id, PFTEMP) < 0)
  800fa1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa8:	00 
  800fa9:	89 1c 24             	mov    %ebx,(%esp)
  800fac:	e8 7b fd ff ff       	call   800d2c <sys_page_unmap>
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 1c                	jns    800fd1 <pgfault+0x135>
            panic("pafault fail at page_unmap PFTEMP!\n");
  800fb5:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  800fcc:	e8 0b 04 00 00       	call   8013dc <_panic>
	//panic("pgfault not implemented");
}
  800fd1:	83 c4 20             	add    $0x20,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
        set_pgfault_handler(pgfault);
  800fe1:	c7 04 24 9c 0e 80 00 	movl   $0x800e9c,(%esp)
  800fe8:	e8 47 04 00 00       	call   801434 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fed:	ba 07 00 00 00       	mov    $0x7,%edx
  800ff2:	89 d0                	mov    %edx,%eax
  800ff4:	cd 30                	int    $0x30
  800ff6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ff9:	89 45 d8             	mov    %eax,-0x28(%ebp)
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	79 1c                	jns    80101c <fork+0x44>
            panic("fork fail at sys_exofork!\n");
  801000:	c7 44 24 08 7a 1b 80 	movl   $0x801b7a,0x8(%esp)
  801007:	00 
  801008:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80100f:	00 
  801010:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  801017:	e8 c0 03 00 00       	call   8013dc <_panic>
        else if(env_id == 0){
  80101c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801020:	75 25                	jne    801047 <fork+0x6f>
            thisenv = &envs[ENVX(sys_getenvid())];
  801022:	e8 20 fc ff ff       	call   800c47 <sys_getenvid>
  801027:	25 ff 03 00 00       	and    $0x3ff,%eax
  80102c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801033:	c1 e0 07             	shl    $0x7,%eax
  801036:	29 d0                	sub    %edx,%eax
  801038:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103d:	a3 0c 20 80 00       	mov    %eax,0x80200c
            return 0;
  801042:	e9 51 02 00 00       	jmp    801298 <fork+0x2c0>
        set_pgfault_handler(pgfault);
        envid_t env_id;
        uint32_t addr;
        if((env_id = sys_exofork()) < 0)
            panic("fork fail at sys_exofork!\n");
        else if(env_id == 0){
  801047:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
  80104e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801051:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  801058:	a8 01                	test   $0x1,%al
  80105a:	0f 84 ea 00 00 00    	je     80114a <fork+0x172>
                    for(j = 0; j < NPTENTRIES; j++){
                        pn = PGNUM(PGADDR(i,j,0)); 
  801060:	c1 e2 16             	shl    $0x16,%edx
  801063:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801066:	be 00 00 00 00       	mov    $0x0,%esi
  80106b:	89 f3                	mov    %esi,%ebx
  80106d:	c1 e3 0c             	shl    $0xc,%ebx
  801070:	0b 5d e4             	or     -0x1c(%ebp),%ebx
  801073:	c1 eb 0c             	shr    $0xc,%ebx
                        if(pn == PGNUM(UTOP - PGSIZE))
  801076:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80107c:	0f 84 c8 00 00 00    	je     80114a <fork+0x172>
                            break;
                        if(uvpt[pn] & PTE_P)
  801082:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801089:	a8 01                	test   $0x1,%al
  80108b:	0f 84 ac 00 00 00    	je     80113d <fork+0x165>
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
  801091:	e8 b1 fb ff ff       	call   800c47 <sys_getenvid>
  801096:	89 45 e0             	mov    %eax,-0x20(%ebp)
        pte_t pte = uvpt[pn];
  801099:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
        void *addr = (void *)(pn * PGSIZE);
  8010a0:	89 df                	mov    %ebx,%edi
  8010a2:	c1 e7 0c             	shl    $0xc,%edi
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
  8010a5:	25 02 08 00 00       	and    $0x802,%eax
	//panic("duppage not implemented");
        envid_t srcenv_id = sys_getenvid();
        pte_t pte = uvpt[pn];
        void *addr = (void *)(pn * PGSIZE);
        //cprintf("duppage:   envid=%d,r=%d,pn=%d\n",envid,srcenv_id,pn);
        int perm = PTE_P | PTE_U;
  8010aa:	83 f8 01             	cmp    $0x1,%eax
  8010ad:	19 db                	sbb    %ebx,%ebx
  8010af:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8010b5:	81 c3 05 08 00 00    	add    $0x805,%ebx
        if((pte & PTE_W)>0 || (pte & PTE_COW) >0)
            perm |= PTE_COW;
        if(sys_page_map(srcenv_id, addr, envid, addr, PTE_P|PTE_U|PTE_COW) < 0)
  8010bb:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010c2:	00 
  8010c3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 fc fb ff ff       	call   800cd9 <sys_page_map>
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 1c                	jns    8010fd <fork+0x125>
            panic("duppage fail at page map1!\n");
  8010e1:	c7 44 24 08 95 1b 80 	movl   $0x801b95,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  8010f8:	e8 df 02 00 00       	call   8013dc <_panic>
        if(perm & PTE_COW){
  8010fd:	f6 c7 08             	test   $0x8,%bh
  801100:	74 3b                	je     80113d <fork+0x165>
            if(sys_page_map(srcenv_id, addr, srcenv_id, addr, perm) < 0)
  801102:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801106:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80110a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80110d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801111:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 bc fb ff ff       	call   800cd9 <sys_page_map>
  80111d:	85 c0                	test   %eax,%eax
  80111f:	79 1c                	jns    80113d <fork+0x165>
                panic("duppage fail at page map2!\n");
  801121:	c7 44 24 08 b1 1b 80 	movl   $0x801bb1,0x8(%esp)
  801128:	00 
  801129:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  801138:	e8 9f 02 00 00       	call   8013dc <_panic>
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
                if(uvpd[i] & PTE_P){
                    for(j = 0; j < NPTENTRIES; j++){
  80113d:	46                   	inc    %esi
  80113e:	81 fe 00 04 00 00    	cmp    $0x400,%esi
  801144:	0f 85 21 ff ff ff    	jne    80106b <fork+0x93>
            thisenv = &envs[ENVX(sys_getenvid())];
            return 0;
        }
        else{
            int i,j,pn;
            for(i = 0 ; i < PDX(UTOP); i++){
  80114a:	ff 45 dc             	incl   -0x24(%ebp)
  80114d:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  801154:	0f 85 f4 fe ff ff    	jne    80104e <fork+0x76>
                        if(uvpt[pn] & PTE_P)
                            duppage(env_id, pn);
                    }
                }
            }
            if(sys_page_alloc(env_id,(void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  80115a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801169:	ee 
  80116a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80116d:	89 04 24             	mov    %eax,(%esp)
  801170:	e8 10 fb ff ff       	call   800c85 <sys_page_alloc>
  801175:	85 c0                	test   %eax,%eax
  801177:	79 1c                	jns    801195 <fork+0x1bd>
                panic("fork fail at sys_page_alloc!\n");
  801179:	c7 44 24 08 cd 1b 80 	movl   $0x801bcd,0x8(%esp)
  801180:	00 
  801181:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801188:	00 
  801189:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  801190:	e8 47 02 00 00       	call   8013dc <_panic>
            if(sys_page_map(env_id, (void *)(UXSTACKTOP - PGSIZE), sys_getenvid(), PFTEMP, PTE_U|PTE_P|PTE_W) < 0)
  801195:	e8 ad fa ff ff       	call   800c47 <sys_getenvid>
  80119a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  8011a9:	00 
  8011aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ae:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011b5:	ee 
  8011b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011b9:	89 04 24             	mov    %eax,(%esp)
  8011bc:	e8 18 fb ff ff       	call   800cd9 <sys_page_map>
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	79 1c                	jns    8011e1 <fork+0x209>
                panic("fork fail at sys_page_map!\n");
  8011c5:	c7 44 24 08 eb 1b 80 	movl   $0x801beb,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  8011dc:	e8 fb 01 00 00       	call   8013dc <_panic>
            memmove((void *)(UXSTACKTOP - PGSIZE),PFTEMP, PGSIZE);
  8011e1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011e8:	00 
  8011e9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011f0:	00 
  8011f1:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  8011f8:	e8 0f f8 ff ff       	call   800a0c <memmove>
            if(sys_page_unmap(sys_getenvid(), PFTEMP) < 0)
  8011fd:	e8 45 fa ff ff       	call   800c47 <sys_getenvid>
  801202:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801209:	00 
  80120a:	89 04 24             	mov    %eax,(%esp)
  80120d:	e8 1a fb ff ff       	call   800d2c <sys_page_unmap>
  801212:	85 c0                	test   %eax,%eax
  801214:	79 1c                	jns    801232 <fork+0x25a>
                panic("fork fail at sys_page_unmap!\n");
  801216:	c7 44 24 08 07 1c 80 	movl   $0x801c07,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  80122d:	e8 aa 01 00 00       	call   8013dc <_panic>
            
            extern void _pgfault_upcall(void);
            if(sys_env_set_pgfault_upcall(env_id, _pgfault_upcall) < 0)
  801232:	c7 44 24 04 c0 14 80 	movl   $0x8014c0,0x4(%esp)
  801239:	00 
  80123a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	e8 8d fb ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>
  801245:	85 c0                	test   %eax,%eax
  801247:	79 1c                	jns    801265 <fork+0x28d>
                panic("fork fail at sys_env_set_pgfault_upcall!\n");
  801249:	c7 44 24 08 e8 1a 80 	movl   $0x801ae8,0x8(%esp)
  801250:	00 
  801251:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801258:	00 
  801259:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  801260:	e8 77 01 00 00       	call   8013dc <_panic>
            if(sys_env_set_status(env_id,ENV_RUNNABLE) < 0)
  801265:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80126c:	00 
  80126d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801270:	89 04 24             	mov    %eax,(%esp)
  801273:	e8 07 fb ff ff       	call   800d7f <sys_env_set_status>
  801278:	85 c0                	test   %eax,%eax
  80127a:	79 1c                	jns    801298 <fork+0x2c0>
                panic("fork fail at sys_env_set_status!\n");
  80127c:	c7 44 24 08 14 1b 80 	movl   $0x801b14,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  801293:	e8 44 01 00 00       	call   8013dc <_panic>
            return env_id;
        }
}
  801298:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80129b:	83 c4 4c             	add    $0x4c,%esp
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <sfork>:

// Challenge!
int
sfork(void)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012a9:	c7 44 24 08 25 1c 80 	movl   $0x801c25,0x8(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
  8012b8:	00 
  8012b9:	c7 04 24 36 1b 80 00 	movl   $0x801b36,(%esp)
  8012c0:	e8 17 01 00 00       	call   8013dc <_panic>
  8012c5:	00 00                	add    %al,(%eax)
	...

008012c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 10             	sub    $0x10,%esp
  8012d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
        if(!pg)
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	75 05                	jne    8012e2 <ipc_recv+0x1a>
            pg = (void *)-1;
  8012dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        int32_t ret;
        if((ret = (sys_ipc_recv(pg))) < 0){
  8012e2:	89 04 24             	mov    %eax,(%esp)
  8012e5:	e8 5e fb ff ff       	call   800e48 <sys_ipc_recv>
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	79 16                	jns    801304 <ipc_recv+0x3c>
            if(from_env_store)
  8012ee:	85 db                	test   %ebx,%ebx
  8012f0:	74 06                	je     8012f8 <ipc_recv+0x30>
                *from_env_store = 0;
  8012f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
            if(perm_store)
  8012f8:	85 f6                	test   %esi,%esi
  8012fa:	74 2c                	je     801328 <ipc_recv+0x60>
                *perm_store = 0;
  8012fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801302:	eb 24                	jmp    801328 <ipc_recv+0x60>
            return ret;
        }
        if(from_env_store)
  801304:	85 db                	test   %ebx,%ebx
  801306:	74 0a                	je     801312 <ipc_recv+0x4a>
            *from_env_store = thisenv->env_ipc_from;
  801308:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80130d:	8b 40 74             	mov    0x74(%eax),%eax
  801310:	89 03                	mov    %eax,(%ebx)
        if(perm_store)
  801312:	85 f6                	test   %esi,%esi
  801314:	74 0a                	je     801320 <ipc_recv+0x58>
            *perm_store = thisenv->env_ipc_perm;
  801316:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80131b:	8b 40 78             	mov    0x78(%eax),%eax
  80131e:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801320:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801325:	8b 40 70             	mov    0x70(%eax),%eax
}
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	57                   	push   %edi
  801333:	56                   	push   %esi
  801334:	53                   	push   %ebx
  801335:	83 ec 1c             	sub    $0x1c,%esp
  801338:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80133b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80133e:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg)
  801341:	85 db                	test   %ebx,%ebx
  801343:	75 2d                	jne    801372 <ipc_send+0x43>
            pg = (void *)-1;
  801345:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80134a:	eb 26                	jmp    801372 <ipc_send+0x43>
        int32_t ret;
        while((ret = sys_ipc_try_send(to_env, val, pg, perm)) != 0){
            if(ret != -E_IPC_NOT_RECV)
  80134c:	83 f8 f8             	cmp    $0xfffffff8,%eax
  80134f:	74 1c                	je     80136d <ipc_send+0x3e>
                panic("ipc_send fail at sys_ipc_try_send!\n");
  801351:	c7 44 24 08 3c 1c 80 	movl   $0x801c3c,0x8(%esp)
  801358:	00 
  801359:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801360:	00 
  801361:	c7 04 24 60 1c 80 00 	movl   $0x801c60,(%esp)
  801368:	e8 6f 00 00 00       	call   8013dc <_panic>
            sys_yield();
  80136d:	e8 f4 f8 ff ff       	call   800c66 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
        if(!pg)
            pg = (void *)-1;
        int32_t ret;
        while((ret = sys_ipc_try_send(to_env, val, pg, perm)) != 0){
  801372:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801376:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80137a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	89 04 24             	mov    %eax,(%esp)
  801384:	e8 9c fa ff ff       	call   800e25 <sys_ipc_try_send>
  801389:	85 c0                	test   %eax,%eax
  80138b:	75 bf                	jne    80134c <ipc_send+0x1d>
            if(ret != -E_IPC_NOT_RECV)
                panic("ipc_send fail at sys_ipc_try_send!\n");
            sys_yield();
        }
}
  80138d:	83 c4 1c             	add    $0x1c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80139c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013a1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	c1 e2 07             	shl    $0x7,%edx
  8013ad:	29 ca                	sub    %ecx,%edx
  8013af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b5:	8b 52 50             	mov    0x50(%edx),%edx
  8013b8:	39 da                	cmp    %ebx,%edx
  8013ba:	75 0f                	jne    8013cb <ipc_find_env+0x36>
			return envs[i].env_id;
  8013bc:	c1 e0 07             	shl    $0x7,%eax
  8013bf:	29 c8                	sub    %ecx,%eax
  8013c1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013c6:	8b 40 40             	mov    0x40(%eax),%eax
  8013c9:	eb 0c                	jmp    8013d7 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013cb:	40                   	inc    %eax
  8013cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d1:	75 ce                	jne    8013a1 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d3:	66 b8 00 00          	mov    $0x0,%ax
}
  8013d7:	5b                   	pop    %ebx
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    
	...

008013dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013e7:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8013ed:	e8 55 f8 ff ff       	call   800c47 <sys_getenvid>
  8013f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801400:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	c7 04 24 6c 1c 80 00 	movl   $0x801c6c,(%esp)
  80140f:	e8 d4 ee ff ff       	call   8002e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801414:	89 74 24 04          	mov    %esi,0x4(%esp)
  801418:	8b 45 10             	mov    0x10(%ebp),%eax
  80141b:	89 04 24             	mov    %eax,(%esp)
  80141e:	e8 64 ee ff ff       	call   800287 <vcprintf>
	cprintf("\n");
  801423:	c7 04 24 af 1b 80 00 	movl   $0x801baf,(%esp)
  80142a:	e8 b9 ee ff ff       	call   8002e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80142f:	cc                   	int3   
  801430:	eb fd                	jmp    80142f <_panic+0x53>
	...

00801434 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80143a:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801441:	75 3d                	jne    801480 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  801443:	e8 ff f7 ff ff       	call   800c47 <sys_getenvid>
  801448:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  80144f:	00 
  801450:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801457:	ee 
  801458:	89 04 24             	mov    %eax,(%esp)
  80145b:	e8 25 f8 ff ff       	call   800c85 <sys_page_alloc>
  801460:	85 c0                	test   %eax,%eax
  801462:	79 1c                	jns    801480 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  801464:	c7 44 24 08 90 1c 80 	movl   $0x801c90,0x8(%esp)
  80146b:	00 
  80146c:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801473:	00 
  801474:	c7 04 24 e8 1c 80 00 	movl   $0x801ce8,(%esp)
  80147b:	e8 5c ff ff ff       	call   8013dc <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	a3 10 20 80 00       	mov    %eax,0x802010
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  801488:	e8 ba f7 ff ff       	call   800c47 <sys_getenvid>
  80148d:	c7 44 24 04 c0 14 80 	movl   $0x8014c0,0x4(%esp)
  801494:	00 
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 35 f9 ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>
  80149d:	85 c0                	test   %eax,%eax
  80149f:	79 1c                	jns    8014bd <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  8014a1:	c7 44 24 08 c0 1c 80 	movl   $0x801cc0,0x8(%esp)
  8014a8:	00 
  8014a9:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014b0:	00 
  8014b1:	c7 04 24 e8 1c 80 00 	movl   $0x801ce8,(%esp)
  8014b8:	e8 1f ff ff ff       	call   8013dc <_panic>
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    
	...

008014c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014c1:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8014c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014c8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  8014cb:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  8014cd:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  8014d1:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  8014d5:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  8014d6:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  8014d8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  8014dd:	58                   	pop    %eax
        popl %eax
  8014de:	58                   	pop    %eax
        popal
  8014df:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  8014e0:	83 c4 04             	add    $0x4,%esp
        popfl
  8014e3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8014e4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  8014e5:	c3                   	ret    
	...

008014e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8014e8:	55                   	push   %ebp
  8014e9:	57                   	push   %edi
  8014ea:	56                   	push   %esi
  8014eb:	83 ec 10             	sub    $0x10,%esp
  8014ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8014f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8014f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8014fe:	89 cd                	mov    %ecx,%ebp
  801500:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801504:	85 c0                	test   %eax,%eax
  801506:	75 2c                	jne    801534 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801508:	39 f9                	cmp    %edi,%ecx
  80150a:	77 68                	ja     801574 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80150c:	85 c9                	test   %ecx,%ecx
  80150e:	75 0b                	jne    80151b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801510:	b8 01 00 00 00       	mov    $0x1,%eax
  801515:	31 d2                	xor    %edx,%edx
  801517:	f7 f1                	div    %ecx
  801519:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	89 f8                	mov    %edi,%eax
  80151f:	f7 f1                	div    %ecx
  801521:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801523:	89 f0                	mov    %esi,%eax
  801525:	f7 f1                	div    %ecx
  801527:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801529:	89 f0                	mov    %esi,%eax
  80152b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	5e                   	pop    %esi
  801531:	5f                   	pop    %edi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801534:	39 f8                	cmp    %edi,%eax
  801536:	77 2c                	ja     801564 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801538:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80153b:	83 f6 1f             	xor    $0x1f,%esi
  80153e:	75 4c                	jne    80158c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801540:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801542:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801547:	72 0a                	jb     801553 <__udivdi3+0x6b>
  801549:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80154d:	0f 87 ad 00 00 00    	ja     801600 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801553:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801558:	89 f0                	mov    %esi,%eax
  80155a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
  801563:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801564:	31 ff                	xor    %edi,%edi
  801566:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801568:	89 f0                	mov    %esi,%eax
  80156a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    
  801573:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801574:	89 fa                	mov    %edi,%edx
  801576:	89 f0                	mov    %esi,%eax
  801578:	f7 f1                	div    %ecx
  80157a:	89 c6                	mov    %eax,%esi
  80157c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80157e:	89 f0                	mov    %esi,%eax
  801580:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	5e                   	pop    %esi
  801586:	5f                   	pop    %edi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    
  801589:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80158c:	89 f1                	mov    %esi,%ecx
  80158e:	d3 e0                	shl    %cl,%eax
  801590:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801594:	b8 20 00 00 00       	mov    $0x20,%eax
  801599:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80159b:	89 ea                	mov    %ebp,%edx
  80159d:	88 c1                	mov    %al,%cl
  80159f:	d3 ea                	shr    %cl,%edx
  8015a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8015a5:	09 ca                	or     %ecx,%edx
  8015a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8015ab:	89 f1                	mov    %esi,%ecx
  8015ad:	d3 e5                	shl    %cl,%ebp
  8015af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8015b3:	89 fd                	mov    %edi,%ebp
  8015b5:	88 c1                	mov    %al,%cl
  8015b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8015b9:	89 fa                	mov    %edi,%edx
  8015bb:	89 f1                	mov    %esi,%ecx
  8015bd:	d3 e2                	shl    %cl,%edx
  8015bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015c3:	88 c1                	mov    %al,%cl
  8015c5:	d3 ef                	shr    %cl,%edi
  8015c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015c9:	89 f8                	mov    %edi,%eax
  8015cb:	89 ea                	mov    %ebp,%edx
  8015cd:	f7 74 24 08          	divl   0x8(%esp)
  8015d1:	89 d1                	mov    %edx,%ecx
  8015d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8015d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015d9:	39 d1                	cmp    %edx,%ecx
  8015db:	72 17                	jb     8015f4 <__udivdi3+0x10c>
  8015dd:	74 09                	je     8015e8 <__udivdi3+0x100>
  8015df:	89 fe                	mov    %edi,%esi
  8015e1:	31 ff                	xor    %edi,%edi
  8015e3:	e9 41 ff ff ff       	jmp    801529 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8015e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015ec:	89 f1                	mov    %esi,%ecx
  8015ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015f0:	39 c2                	cmp    %eax,%edx
  8015f2:	73 eb                	jae    8015df <__udivdi3+0xf7>
		{
		  q0--;
  8015f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8015f7:	31 ff                	xor    %edi,%edi
  8015f9:	e9 2b ff ff ff       	jmp    801529 <__udivdi3+0x41>
  8015fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801600:	31 f6                	xor    %esi,%esi
  801602:	e9 22 ff ff ff       	jmp    801529 <__udivdi3+0x41>
	...

00801608 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801608:	55                   	push   %ebp
  801609:	57                   	push   %edi
  80160a:	56                   	push   %esi
  80160b:	83 ec 20             	sub    $0x20,%esp
  80160e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801612:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801616:	89 44 24 14          	mov    %eax,0x14(%esp)
  80161a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80161e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801622:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801626:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801628:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80162a:	85 ed                	test   %ebp,%ebp
  80162c:	75 16                	jne    801644 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80162e:	39 f1                	cmp    %esi,%ecx
  801630:	0f 86 a6 00 00 00    	jbe    8016dc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801636:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801638:	89 d0                	mov    %edx,%eax
  80163a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80163c:	83 c4 20             	add    $0x20,%esp
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    
  801643:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801644:	39 f5                	cmp    %esi,%ebp
  801646:	0f 87 ac 00 00 00    	ja     8016f8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80164c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80164f:	83 f0 1f             	xor    $0x1f,%eax
  801652:	89 44 24 10          	mov    %eax,0x10(%esp)
  801656:	0f 84 a8 00 00 00    	je     801704 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80165c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801660:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801662:	bf 20 00 00 00       	mov    $0x20,%edi
  801667:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80166b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80166f:	89 f9                	mov    %edi,%ecx
  801671:	d3 e8                	shr    %cl,%eax
  801673:	09 e8                	or     %ebp,%eax
  801675:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801679:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80167d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801681:	d3 e0                	shl    %cl,%eax
  801683:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801687:	89 f2                	mov    %esi,%edx
  801689:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80168b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80168f:	d3 e0                	shl    %cl,%eax
  801691:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801695:	8b 44 24 14          	mov    0x14(%esp),%eax
  801699:	89 f9                	mov    %edi,%ecx
  80169b:	d3 e8                	shr    %cl,%eax
  80169d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80169f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8016a1:	89 f2                	mov    %esi,%edx
  8016a3:	f7 74 24 18          	divl   0x18(%esp)
  8016a7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8016a9:	f7 64 24 0c          	mull   0xc(%esp)
  8016ad:	89 c5                	mov    %eax,%ebp
  8016af:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016b1:	39 d6                	cmp    %edx,%esi
  8016b3:	72 67                	jb     80171c <__umoddi3+0x114>
  8016b5:	74 75                	je     80172c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8016b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016bb:	29 e8                	sub    %ebp,%eax
  8016bd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8016bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016c3:	d3 e8                	shr    %cl,%eax
  8016c5:	89 f2                	mov    %esi,%edx
  8016c7:	89 f9                	mov    %edi,%ecx
  8016c9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8016cb:	09 d0                	or     %edx,%eax
  8016cd:	89 f2                	mov    %esi,%edx
  8016cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016d3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016d5:	83 c4 20             	add    $0x20,%esp
  8016d8:	5e                   	pop    %esi
  8016d9:	5f                   	pop    %edi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8016dc:	85 c9                	test   %ecx,%ecx
  8016de:	75 0b                	jne    8016eb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8016e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016e5:	31 d2                	xor    %edx,%edx
  8016e7:	f7 f1                	div    %ecx
  8016e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8016eb:	89 f0                	mov    %esi,%eax
  8016ed:	31 d2                	xor    %edx,%edx
  8016ef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8016f1:	89 f8                	mov    %edi,%eax
  8016f3:	e9 3e ff ff ff       	jmp    801636 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8016f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016fa:	83 c4 20             	add    $0x20,%esp
  8016fd:	5e                   	pop    %esi
  8016fe:	5f                   	pop    %edi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    
  801701:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801704:	39 f5                	cmp    %esi,%ebp
  801706:	72 04                	jb     80170c <__umoddi3+0x104>
  801708:	39 f9                	cmp    %edi,%ecx
  80170a:	77 06                	ja     801712 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80170c:	89 f2                	mov    %esi,%edx
  80170e:	29 cf                	sub    %ecx,%edi
  801710:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801712:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801714:	83 c4 20             	add    $0x20,%esp
  801717:	5e                   	pop    %esi
  801718:	5f                   	pop    %edi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    
  80171b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80171c:	89 d1                	mov    %edx,%ecx
  80171e:	89 c5                	mov    %eax,%ebp
  801720:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801724:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801728:	eb 8d                	jmp    8016b7 <__umoddi3+0xaf>
  80172a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80172c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801730:	72 ea                	jb     80171c <__umoddi3+0x114>
  801732:	89 f1                	mov    %esi,%ecx
  801734:	eb 81                	jmp    8016b7 <__umoddi3+0xaf>
