
obj/kern/kernel��     �ļ���ʽ elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 1e 33 f0 00 	cmpl   $0x0,0xf0331e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 1e 33 f0    	mov    %esi,0xf0331e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 28 67 00 00       	call   f010678c <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 60 6e 10 f0 	movl   $0xf0106e60,(%esp)
f010007d:	e8 94 3f 00 00       	call   f0104016 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 55 3f 00 00       	call   f0103fe3 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 f6 7f 10 f0 	movl   $0xf0107ff6,(%esp)
f0100095:	e8 7c 3f 00 00       	call   f0104016 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 c9 08 00 00       	call   f010096f <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 cb 6e 10 f0 	movl   $0xf0106ecb,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 a5 66 00 00       	call   f010678c <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 d7 6e 10 f0 	movl   $0xf0106ed7,(%esp)
f01000f2:	e8 1f 3f 00 00       	call   f0104016 <cprintf>

	lapic_init();
f01000f7:	e8 ab 66 00 00       	call   f01067a7 <lapic_init>
	env_init_percpu();
f01000fc:	e8 e4 35 00 00       	call   f01036e5 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 2a 3f 00 00       	call   f0104030 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 81 66 00 00       	call   f010678c <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 20 33 f0    	add    $0xf0332020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100124:	e8 22 69 00 00       	call   f0106a4b <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:

        lock_kernel();
        sched_yield();
f0100129:	e8 60 4d 00 00       	call   f0104e8e <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 30 37 f0       	mov    $0xf0373008,%eax
f010013a:	2d 2e 00 33 f0       	sub    $0xf033002e,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 2e 00 33 f0 	movl   $0xf033002e,(%esp)
f0100152:	e8 07 60 00 00       	call   f010615e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 17 05 00 00       	call   f0100673 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 ed 6e 10 f0 	movl   $0xf0106eed,(%esp)
f010016b:	e8 a6 3e 00 00       	call   f0104016 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 b3 12 00 00       	call   f0101428 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 95 35 00 00       	call   f010370f <env_init>
	trap_init();
f010017a:	e8 a5 3f 00 00       	call   f0104124 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	e8 20 63 00 00       	call   f01064a4 <mp_init>
	lapic_init();
f0100184:	e8 1e 66 00 00       	call   f01067a7 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100189:	e8 de 3d 00 00       	call   f0103f6c <pic_init>
f010018e:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100195:	e8 b1 68 00 00       	call   f0106a4b <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010019a:	83 3d 88 1e 33 f0 07 	cmpl   $0x7,0xf0331e88
f01001a1:	77 24                	ja     f01001c7 <i386_init+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001a3:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001aa:	00 
f01001ab:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01001b2:	f0 
f01001b3:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
f01001ba:	00 
f01001bb:	c7 04 24 cb 6e 10 f0 	movl   $0xf0106ecb,(%esp)
f01001c2:	e8 79 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c7:	b8 ce 63 10 f0       	mov    $0xf01063ce,%eax
f01001cc:	2d 54 63 10 f0       	sub    $0xf0106354,%eax
f01001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d5:	c7 44 24 04 54 63 10 	movl   $0xf0106354,0x4(%esp)
f01001dc:	f0 
f01001dd:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e4:	e8 bf 5f 00 00       	call   f01061a8 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e9:	bb 20 20 33 f0       	mov    $0xf0332020,%ebx
f01001ee:	eb 6f                	jmp    f010025f <i386_init+0x131>
		if (c == cpus + cpunum())  // We've started already.
f01001f0:	e8 97 65 00 00       	call   f010678c <cpunum>
f01001f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001fc:	29 c2                	sub    %eax,%edx
f01001fe:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100201:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0100208:	39 c3                	cmp    %eax,%ebx
f010020a:	74 50                	je     f010025c <i386_init+0x12e>

static void boot_aps(void);


void
i386_init(void)
f010020c:	89 d8                	mov    %ebx,%eax
f010020e:	2d 20 20 33 f0       	sub    $0xf0332020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100213:	c1 f8 02             	sar    $0x2,%eax
f0100216:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100219:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f010021c:	89 d1                	mov    %edx,%ecx
f010021e:	c1 e1 05             	shl    $0x5,%ecx
f0100221:	29 d1                	sub    %edx,%ecx
f0100223:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100226:	89 d1                	mov    %edx,%ecx
f0100228:	c1 e1 0e             	shl    $0xe,%ecx
f010022b:	29 d1                	sub    %edx,%ecx
f010022d:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100230:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100234:	c1 e0 0f             	shl    $0xf,%eax
f0100237:	05 00 30 33 f0       	add    $0xf0333000,%eax
f010023c:	a3 84 1e 33 f0       	mov    %eax,0xf0331e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100241:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100248:	00 
f0100249:	0f b6 03             	movzbl (%ebx),%eax
f010024c:	89 04 24             	mov    %eax,(%esp)
f010024f:	e8 ac 66 00 00       	call   f0106900 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100254:	8b 43 04             	mov    0x4(%ebx),%eax
f0100257:	83 f8 01             	cmp    $0x1,%eax
f010025a:	75 f8                	jne    f0100254 <i386_init+0x126>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010025c:	83 c3 74             	add    $0x74,%ebx
f010025f:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f0100264:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010026b:	29 c2                	sub    %eax,%edx
f010026d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100270:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0100277:	39 c3                	cmp    %eax,%ebx
f0100279:	0f 82 71 ff ff ff    	jb     f01001f0 <i386_init+0xc2>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010027f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100286:	00 
f0100287:	c7 04 24 f4 93 12 f0 	movl   $0xf01293f4,(%esp)
f010028e:	e8 a4 36 00 00       	call   f0103937 <env_create>
        ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

//<<<<<<< HEAD
	// Schedule and run the first user environment!
	sched_yield();
f0100293:	e8 f6 4b 00 00       	call   f0104e8e <sched_yield>

f0100298 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100298:	55                   	push   %ebp
f0100299:	89 e5                	mov    %esp,%ebp
f010029b:	53                   	push   %ebx
f010029c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010029f:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002b0:	c7 04 24 08 6f 10 f0 	movl   $0xf0106f08,(%esp)
f01002b7:	e8 5a 3d 00 00       	call   f0104016 <cprintf>
	vcprintf(fmt, ap);
f01002bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002c0:	8b 45 10             	mov    0x10(%ebp),%eax
f01002c3:	89 04 24             	mov    %eax,(%esp)
f01002c6:	e8 18 3d 00 00       	call   f0103fe3 <vcprintf>
	cprintf("\n");
f01002cb:	c7 04 24 f6 7f 10 f0 	movl   $0xf0107ff6,(%esp)
f01002d2:	e8 3f 3d 00 00       	call   f0104016 <cprintf>
	va_end(ap);
}
f01002d7:	83 c4 14             	add    $0x14,%esp
f01002da:	5b                   	pop    %ebx
f01002db:	5d                   	pop    %ebp
f01002dc:	c3                   	ret    
f01002dd:	00 00                	add    %al,(%eax)
	...

f01002e0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002e0:	55                   	push   %ebp
f01002e1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002ec:	5d                   	pop    %ebp
f01002ed:	c3                   	ret    

f01002ee <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ee:	55                   	push   %ebp
f01002ef:	89 e5                	mov    %esp,%ebp
f01002f1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002f6:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002f7:	a8 01                	test   $0x1,%al
f01002f9:	74 08                	je     f0100303 <serial_proc_data+0x15>
f01002fb:	b2 f8                	mov    $0xf8,%dl
f01002fd:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002fe:	0f b6 c0             	movzbl %al,%eax
f0100301:	eb 05                	jmp    f0100308 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100303:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100308:	5d                   	pop    %ebp
f0100309:	c3                   	ret    

f010030a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010030a:	55                   	push   %ebp
f010030b:	89 e5                	mov    %esp,%ebp
f010030d:	53                   	push   %ebx
f010030e:	83 ec 04             	sub    $0x4,%esp
f0100311:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100313:	eb 29                	jmp    f010033e <cons_intr+0x34>
		if (c == 0)
f0100315:	85 c0                	test   %eax,%eax
f0100317:	74 25                	je     f010033e <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100319:	8b 15 24 12 33 f0    	mov    0xf0331224,%edx
f010031f:	88 82 20 10 33 f0    	mov    %al,-0xfccefe0(%edx)
f0100325:	8d 42 01             	lea    0x1(%edx),%eax
f0100328:	a3 24 12 33 f0       	mov    %eax,0xf0331224
		if (cons.wpos == CONSBUFSIZE)
f010032d:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100332:	75 0a                	jne    f010033e <cons_intr+0x34>
			cons.wpos = 0;
f0100334:	c7 05 24 12 33 f0 00 	movl   $0x0,0xf0331224
f010033b:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010033e:	ff d3                	call   *%ebx
f0100340:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100343:	75 d0                	jne    f0100315 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100345:	83 c4 04             	add    $0x4,%esp
f0100348:	5b                   	pop    %ebx
f0100349:	5d                   	pop    %ebp
f010034a:	c3                   	ret    

f010034b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034b:	55                   	push   %ebp
f010034c:	89 e5                	mov    %esp,%ebp
f010034e:	57                   	push   %edi
f010034f:	56                   	push   %esi
f0100350:	53                   	push   %ebx
f0100351:	83 ec 2c             	sub    $0x2c,%esp
f0100354:	89 c6                	mov    %eax,%esi
f0100356:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010035b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100360:	eb 05                	jmp    f0100367 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100362:	e8 79 ff ff ff       	call   f01002e0 <delay>
f0100367:	89 fa                	mov    %edi,%edx
f0100369:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010036a:	a8 20                	test   $0x20,%al
f010036c:	75 03                	jne    f0100371 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010036e:	4b                   	dec    %ebx
f010036f:	75 f1                	jne    f0100362 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100371:	89 f2                	mov    %esi,%edx
f0100373:	89 f0                	mov    %esi,%eax
f0100375:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100378:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010037d:	ee                   	out    %al,(%dx)
f010037e:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100383:	bf 79 03 00 00       	mov    $0x379,%edi
f0100388:	eb 05                	jmp    f010038f <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f010038a:	e8 51 ff ff ff       	call   f01002e0 <delay>
f010038f:	89 fa                	mov    %edi,%edx
f0100391:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100392:	84 c0                	test   %al,%al
f0100394:	78 03                	js     f0100399 <cons_putc+0x4e>
f0100396:	4b                   	dec    %ebx
f0100397:	75 f1                	jne    f010038a <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100399:	ba 78 03 00 00       	mov    $0x378,%edx
f010039e:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003a1:	ee                   	out    %al,(%dx)
f01003a2:	b2 7a                	mov    $0x7a,%dl
f01003a4:	b0 0d                	mov    $0xd,%al
f01003a6:	ee                   	out    %al,(%dx)
f01003a7:	b0 08                	mov    $0x8,%al
f01003a9:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003aa:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003b0:	75 06                	jne    f01003b8 <cons_putc+0x6d>
		c |= 0x0700;
f01003b2:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003b8:	89 f0                	mov    %esi,%eax
f01003ba:	25 ff 00 00 00       	and    $0xff,%eax
f01003bf:	83 f8 09             	cmp    $0x9,%eax
f01003c2:	74 78                	je     f010043c <cons_putc+0xf1>
f01003c4:	83 f8 09             	cmp    $0x9,%eax
f01003c7:	7f 0b                	jg     f01003d4 <cons_putc+0x89>
f01003c9:	83 f8 08             	cmp    $0x8,%eax
f01003cc:	0f 85 9e 00 00 00    	jne    f0100470 <cons_putc+0x125>
f01003d2:	eb 10                	jmp    f01003e4 <cons_putc+0x99>
f01003d4:	83 f8 0a             	cmp    $0xa,%eax
f01003d7:	74 39                	je     f0100412 <cons_putc+0xc7>
f01003d9:	83 f8 0d             	cmp    $0xd,%eax
f01003dc:	0f 85 8e 00 00 00    	jne    f0100470 <cons_putc+0x125>
f01003e2:	eb 36                	jmp    f010041a <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003e4:	66 a1 34 12 33 f0    	mov    0xf0331234,%ax
f01003ea:	66 85 c0             	test   %ax,%ax
f01003ed:	0f 84 e2 00 00 00    	je     f01004d5 <cons_putc+0x18a>
			crt_pos--;
f01003f3:	48                   	dec    %eax
f01003f4:	66 a3 34 12 33 f0    	mov    %ax,0xf0331234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003fa:	0f b7 c0             	movzwl %ax,%eax
f01003fd:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100403:	83 ce 20             	or     $0x20,%esi
f0100406:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
f010040c:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100410:	eb 78                	jmp    f010048a <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100412:	66 83 05 34 12 33 f0 	addw   $0x50,0xf0331234
f0100419:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010041a:	66 8b 0d 34 12 33 f0 	mov    0xf0331234,%cx
f0100421:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100426:	89 c8                	mov    %ecx,%eax
f0100428:	ba 00 00 00 00       	mov    $0x0,%edx
f010042d:	66 f7 f3             	div    %bx
f0100430:	66 29 d1             	sub    %dx,%cx
f0100433:	66 89 0d 34 12 33 f0 	mov    %cx,0xf0331234
f010043a:	eb 4e                	jmp    f010048a <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f010043c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100441:	e8 05 ff ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 fb fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 f1 fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f010045a:	b8 20 00 00 00       	mov    $0x20,%eax
f010045f:	e8 e7 fe ff ff       	call   f010034b <cons_putc>
		cons_putc(' ');
f0100464:	b8 20 00 00 00       	mov    $0x20,%eax
f0100469:	e8 dd fe ff ff       	call   f010034b <cons_putc>
f010046e:	eb 1a                	jmp    f010048a <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100470:	66 a1 34 12 33 f0    	mov    0xf0331234,%ax
f0100476:	0f b7 c8             	movzwl %ax,%ecx
f0100479:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
f010047f:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100483:	40                   	inc    %eax
f0100484:	66 a3 34 12 33 f0    	mov    %ax,0xf0331234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010048a:	66 81 3d 34 12 33 f0 	cmpw   $0x7cf,0xf0331234
f0100491:	cf 07 
f0100493:	76 40                	jbe    f01004d5 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100495:	a1 30 12 33 f0       	mov    0xf0331230,%eax
f010049a:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004a1:	00 
f01004a2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004a8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004ac:	89 04 24             	mov    %eax,(%esp)
f01004af:	e8 f4 5c 00 00       	call   f01061a8 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004b4:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ba:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004bf:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c5:	40                   	inc    %eax
f01004c6:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004cb:	75 f2                	jne    f01004bf <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004cd:	66 83 2d 34 12 33 f0 	subw   $0x50,0xf0331234
f01004d4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004d5:	8b 0d 2c 12 33 f0    	mov    0xf033122c,%ecx
f01004db:	b0 0e                	mov    $0xe,%al
f01004dd:	89 ca                	mov    %ecx,%edx
f01004df:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e0:	66 8b 35 34 12 33 f0 	mov    0xf0331234,%si
f01004e7:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004ea:	89 f0                	mov    %esi,%eax
f01004ec:	66 c1 e8 08          	shr    $0x8,%ax
f01004f0:	89 da                	mov    %ebx,%edx
f01004f2:	ee                   	out    %al,(%dx)
f01004f3:	b0 0f                	mov    $0xf,%al
f01004f5:	89 ca                	mov    %ecx,%edx
f01004f7:	ee                   	out    %al,(%dx)
f01004f8:	89 f0                	mov    %esi,%eax
f01004fa:	89 da                	mov    %ebx,%edx
f01004fc:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004fd:	83 c4 2c             	add    $0x2c,%esp
f0100500:	5b                   	pop    %ebx
f0100501:	5e                   	pop    %esi
f0100502:	5f                   	pop    %edi
f0100503:	5d                   	pop    %ebp
f0100504:	c3                   	ret    

f0100505 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100505:	55                   	push   %ebp
f0100506:	89 e5                	mov    %esp,%ebp
f0100508:	53                   	push   %ebx
f0100509:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010050c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100511:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100512:	a8 01                	test   $0x1,%al
f0100514:	0f 84 d8 00 00 00    	je     f01005f2 <kbd_proc_data+0xed>
f010051a:	b2 60                	mov    $0x60,%dl
f010051c:	ec                   	in     (%dx),%al
f010051d:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010051f:	3c e0                	cmp    $0xe0,%al
f0100521:	75 11                	jne    f0100534 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100523:	83 0d 28 12 33 f0 40 	orl    $0x40,0xf0331228
		return 0;
f010052a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010052f:	e9 c3 00 00 00       	jmp    f01005f7 <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100534:	84 c0                	test   %al,%al
f0100536:	79 33                	jns    f010056b <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100538:	8b 0d 28 12 33 f0    	mov    0xf0331228,%ecx
f010053e:	f6 c1 40             	test   $0x40,%cl
f0100541:	75 05                	jne    f0100548 <kbd_proc_data+0x43>
f0100543:	88 c2                	mov    %al,%dl
f0100545:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100548:	0f b6 d2             	movzbl %dl,%edx
f010054b:	8a 82 60 6f 10 f0    	mov    -0xfef90a0(%edx),%al
f0100551:	83 c8 40             	or     $0x40,%eax
f0100554:	0f b6 c0             	movzbl %al,%eax
f0100557:	f7 d0                	not    %eax
f0100559:	21 c1                	and    %eax,%ecx
f010055b:	89 0d 28 12 33 f0    	mov    %ecx,0xf0331228
		return 0;
f0100561:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100566:	e9 8c 00 00 00       	jmp    f01005f7 <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f010056b:	8b 0d 28 12 33 f0    	mov    0xf0331228,%ecx
f0100571:	f6 c1 40             	test   $0x40,%cl
f0100574:	74 0e                	je     f0100584 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100576:	88 c2                	mov    %al,%dl
f0100578:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010057e:	89 0d 28 12 33 f0    	mov    %ecx,0xf0331228
	}

	shift |= shiftcode[data];
f0100584:	0f b6 d2             	movzbl %dl,%edx
f0100587:	0f b6 82 60 6f 10 f0 	movzbl -0xfef90a0(%edx),%eax
f010058e:	0b 05 28 12 33 f0    	or     0xf0331228,%eax
	shift ^= togglecode[data];
f0100594:	0f b6 8a 60 70 10 f0 	movzbl -0xfef8fa0(%edx),%ecx
f010059b:	31 c8                	xor    %ecx,%eax
f010059d:	a3 28 12 33 f0       	mov    %eax,0xf0331228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a2:	89 c1                	mov    %eax,%ecx
f01005a4:	83 e1 03             	and    $0x3,%ecx
f01005a7:	8b 0c 8d 60 71 10 f0 	mov    -0xfef8ea0(,%ecx,4),%ecx
f01005ae:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005b2:	a8 08                	test   $0x8,%al
f01005b4:	74 18                	je     f01005ce <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005b6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005b9:	83 fa 19             	cmp    $0x19,%edx
f01005bc:	77 05                	ja     f01005c3 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005be:	83 eb 20             	sub    $0x20,%ebx
f01005c1:	eb 0b                	jmp    f01005ce <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005c3:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005c6:	83 fa 19             	cmp    $0x19,%edx
f01005c9:	77 03                	ja     f01005ce <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005cb:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005ce:	f7 d0                	not    %eax
f01005d0:	a8 06                	test   $0x6,%al
f01005d2:	75 23                	jne    f01005f7 <kbd_proc_data+0xf2>
f01005d4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005da:	75 1b                	jne    f01005f7 <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f01005dc:	c7 04 24 22 6f 10 f0 	movl   $0xf0106f22,(%esp)
f01005e3:	e8 2e 3a 00 00       	call   f0104016 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01005ed:	b0 03                	mov    $0x3,%al
f01005ef:	ee                   	out    %al,(%dx)
f01005f0:	eb 05                	jmp    f01005f7 <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01005f2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005f7:	89 d8                	mov    %ebx,%eax
f01005f9:	83 c4 14             	add    $0x14,%esp
f01005fc:	5b                   	pop    %ebx
f01005fd:	5d                   	pop    %ebp
f01005fe:	c3                   	ret    

f01005ff <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005ff:	55                   	push   %ebp
f0100600:	89 e5                	mov    %esp,%ebp
f0100602:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100605:	80 3d 00 10 33 f0 00 	cmpb   $0x0,0xf0331000
f010060c:	74 0a                	je     f0100618 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010060e:	b8 ee 02 10 f0       	mov    $0xf01002ee,%eax
f0100613:	e8 f2 fc ff ff       	call   f010030a <cons_intr>
}
f0100618:	c9                   	leave  
f0100619:	c3                   	ret    

f010061a <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010061a:	55                   	push   %ebp
f010061b:	89 e5                	mov    %esp,%ebp
f010061d:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100620:	b8 05 05 10 f0       	mov    $0xf0100505,%eax
f0100625:	e8 e0 fc ff ff       	call   f010030a <cons_intr>
}
f010062a:	c9                   	leave  
f010062b:	c3                   	ret    

f010062c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010062c:	55                   	push   %ebp
f010062d:	89 e5                	mov    %esp,%ebp
f010062f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100632:	e8 c8 ff ff ff       	call   f01005ff <serial_intr>
	kbd_intr();
f0100637:	e8 de ff ff ff       	call   f010061a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010063c:	8b 15 20 12 33 f0    	mov    0xf0331220,%edx
f0100642:	3b 15 24 12 33 f0    	cmp    0xf0331224,%edx
f0100648:	74 22                	je     f010066c <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010064a:	0f b6 82 20 10 33 f0 	movzbl -0xfccefe0(%edx),%eax
f0100651:	42                   	inc    %edx
f0100652:	89 15 20 12 33 f0    	mov    %edx,0xf0331220
		if (cons.rpos == CONSBUFSIZE)
f0100658:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010065e:	75 11                	jne    f0100671 <cons_getc+0x45>
			cons.rpos = 0;
f0100660:	c7 05 20 12 33 f0 00 	movl   $0x0,0xf0331220
f0100667:	00 00 00 
f010066a:	eb 05                	jmp    f0100671 <cons_getc+0x45>
		return c;
	}
	return 0;
f010066c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100671:	c9                   	leave  
f0100672:	c3                   	ret    

f0100673 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100673:	55                   	push   %ebp
f0100674:	89 e5                	mov    %esp,%ebp
f0100676:	57                   	push   %edi
f0100677:	56                   	push   %esi
f0100678:	53                   	push   %ebx
f0100679:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010067c:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100683:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010068a:	5a a5 
	if (*cp != 0xA55A) {
f010068c:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100692:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100696:	74 11                	je     f01006a9 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100698:	c7 05 2c 12 33 f0 b4 	movl   $0x3b4,0xf033122c
f010069f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006a2:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006a7:	eb 16                	jmp    f01006bf <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006a9:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b0:	c7 05 2c 12 33 f0 d4 	movl   $0x3d4,0xf033122c
f01006b7:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006ba:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006bf:	8b 0d 2c 12 33 f0    	mov    0xf033122c,%ecx
f01006c5:	b0 0e                	mov    $0xe,%al
f01006c7:	89 ca                	mov    %ecx,%edx
f01006c9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ca:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	0f b6 f8             	movzbl %al,%edi
f01006d3:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d6:	b0 0f                	mov    $0xf,%al
f01006d8:	89 ca                	mov    %ecx,%edx
f01006da:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006db:	89 da                	mov    %ebx,%edx
f01006dd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006de:	89 35 30 12 33 f0    	mov    %esi,0xf0331230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e4:	0f b6 d8             	movzbl %al,%ebx
f01006e7:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006e9:	66 89 3d 34 12 33 f0 	mov    %di,0xf0331234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f0:	e8 25 ff ff ff       	call   f010061a <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f5:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f01006fc:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100701:	89 04 24             	mov    %eax,(%esp)
f0100704:	e8 ef 37 00 00       	call   f0103ef8 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100709:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010070e:	b0 00                	mov    $0x0,%al
f0100710:	89 da                	mov    %ebx,%edx
f0100712:	ee                   	out    %al,(%dx)
f0100713:	b2 fb                	mov    $0xfb,%dl
f0100715:	b0 80                	mov    $0x80,%al
f0100717:	ee                   	out    %al,(%dx)
f0100718:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010071d:	b0 0c                	mov    $0xc,%al
f010071f:	89 ca                	mov    %ecx,%edx
f0100721:	ee                   	out    %al,(%dx)
f0100722:	b2 f9                	mov    $0xf9,%dl
f0100724:	b0 00                	mov    $0x0,%al
f0100726:	ee                   	out    %al,(%dx)
f0100727:	b2 fb                	mov    $0xfb,%dl
f0100729:	b0 03                	mov    $0x3,%al
f010072b:	ee                   	out    %al,(%dx)
f010072c:	b2 fc                	mov    $0xfc,%dl
f010072e:	b0 00                	mov    $0x0,%al
f0100730:	ee                   	out    %al,(%dx)
f0100731:	b2 f9                	mov    $0xf9,%dl
f0100733:	b0 01                	mov    $0x1,%al
f0100735:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100736:	b2 fd                	mov    $0xfd,%dl
f0100738:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100739:	3c ff                	cmp    $0xff,%al
f010073b:	0f 95 45 e7          	setne  -0x19(%ebp)
f010073f:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100742:	a2 00 10 33 f0       	mov    %al,0xf0331000
f0100747:	89 da                	mov    %ebx,%edx
f0100749:	ec                   	in     (%dx),%al
f010074a:	89 ca                	mov    %ecx,%edx
f010074c:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010074d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100751:	75 0c                	jne    f010075f <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f0100753:	c7 04 24 2e 6f 10 f0 	movl   $0xf0106f2e,(%esp)
f010075a:	e8 b7 38 00 00       	call   f0104016 <cprintf>
}
f010075f:	83 c4 2c             	add    $0x2c,%esp
f0100762:	5b                   	pop    %ebx
f0100763:	5e                   	pop    %esi
f0100764:	5f                   	pop    %edi
f0100765:	5d                   	pop    %ebp
f0100766:	c3                   	ret    

f0100767 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100767:	55                   	push   %ebp
f0100768:	89 e5                	mov    %esp,%ebp
f010076a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100770:	e8 d6 fb ff ff       	call   f010034b <cons_putc>
}
f0100775:	c9                   	leave  
f0100776:	c3                   	ret    

f0100777 <getchar>:

int
getchar(void)
{
f0100777:	55                   	push   %ebp
f0100778:	89 e5                	mov    %esp,%ebp
f010077a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077d:	e8 aa fe ff ff       	call   f010062c <cons_getc>
f0100782:	85 c0                	test   %eax,%eax
f0100784:	74 f7                	je     f010077d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100786:	c9                   	leave  
f0100787:	c3                   	ret    

f0100788 <iscons>:

int
iscons(int fdnum)
{
f0100788:	55                   	push   %ebp
f0100789:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010078b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100790:	5d                   	pop    %ebp
f0100791:	c3                   	ret    
	...

f0100794 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100794:	55                   	push   %ebp
f0100795:	89 e5                	mov    %esp,%ebp
f0100797:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010079a:	c7 04 24 70 71 10 f0 	movl   $0xf0107170,(%esp)
f01007a1:	e8 70 38 00 00       	call   f0104016 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007a6:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007ad:	00 
f01007ae:	c7 04 24 18 72 10 f0 	movl   $0xf0107218,(%esp)
f01007b5:	e8 5c 38 00 00       	call   f0104016 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ba:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007c1:	00 
f01007c2:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007c9:	f0 
f01007ca:	c7 04 24 40 72 10 f0 	movl   $0xf0107240,(%esp)
f01007d1:	e8 40 38 00 00       	call   f0104016 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007d6:	c7 44 24 08 4a 6e 10 	movl   $0x106e4a,0x8(%esp)
f01007dd:	00 
f01007de:	c7 44 24 04 4a 6e 10 	movl   $0xf0106e4a,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 64 72 10 f0 	movl   $0xf0107264,(%esp)
f01007ed:	e8 24 38 00 00       	call   f0104016 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007f2:	c7 44 24 08 2e 00 33 	movl   $0x33002e,0x8(%esp)
f01007f9:	00 
f01007fa:	c7 44 24 04 2e 00 33 	movl   $0xf033002e,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 88 72 10 f0 	movl   $0xf0107288,(%esp)
f0100809:	e8 08 38 00 00       	call   f0104016 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010080e:	c7 44 24 08 08 30 37 	movl   $0x373008,0x8(%esp)
f0100815:	00 
f0100816:	c7 44 24 04 08 30 37 	movl   $0xf0373008,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 ac 72 10 f0 	movl   $0xf01072ac,(%esp)
f0100825:	e8 ec 37 00 00       	call   f0104016 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010082a:	b8 07 34 37 f0       	mov    $0xf0373407,%eax
f010082f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100834:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100839:	89 c2                	mov    %eax,%edx
f010083b:	85 c0                	test   %eax,%eax
f010083d:	79 06                	jns    f0100845 <mon_kerninfo+0xb1>
f010083f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100845:	c1 fa 0a             	sar    $0xa,%edx
f0100848:	89 54 24 04          	mov    %edx,0x4(%esp)
f010084c:	c7 04 24 d0 72 10 f0 	movl   $0xf01072d0,(%esp)
f0100853:	e8 be 37 00 00       	call   f0104016 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100858:	b8 00 00 00 00       	mov    $0x0,%eax
f010085d:	c9                   	leave  
f010085e:	c3                   	ret    

f010085f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010085f:	55                   	push   %ebp
f0100860:	89 e5                	mov    %esp,%ebp
f0100862:	53                   	push   %ebx
f0100863:	83 ec 14             	sub    $0x14,%esp
f0100866:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010086b:	8b 83 c4 73 10 f0    	mov    -0xfef8c3c(%ebx),%eax
f0100871:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100875:	8b 83 c0 73 10 f0    	mov    -0xfef8c40(%ebx),%eax
f010087b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087f:	c7 04 24 89 71 10 f0 	movl   $0xf0107189,(%esp)
f0100886:	e8 8b 37 00 00       	call   f0104016 <cprintf>
f010088b:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010088e:	83 fb 24             	cmp    $0x24,%ebx
f0100891:	75 d8                	jne    f010086b <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100893:	b8 00 00 00 00       	mov    $0x0,%eax
f0100898:	83 c4 14             	add    $0x14,%esp
f010089b:	5b                   	pop    %ebx
f010089c:	5d                   	pop    %ebp
f010089d:	c3                   	ret    

f010089e <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	55                   	push   %ebp
f010089f:	89 e5                	mov    %esp,%ebp
f01008a1:	57                   	push   %edi
f01008a2:	56                   	push   %esi
f01008a3:	53                   	push   %ebx
f01008a4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	// Your code here.
        cprintf("Stack backtrace:\n");
f01008aa:	c7 04 24 92 71 10 f0 	movl   $0xf0107192,(%esp)
f01008b1:	e8 60 37 00 00       	call   f0104016 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b6:	89 e8                	mov    %ebp,%eax
f01008b8:	89 c3                	mov    %eax,%ebx
        uint32_t ebp = read_ebp();
	uint32_t old_ebp = *(uint32_t *) ebp;
f01008ba:	8b 38                	mov    (%eax),%edi
        uint32_t ret = *(((uint32_t *) ebp) + 1);
f01008bc:	8b 70 04             	mov    0x4(%eax),%esi
        uint32_t old_ret = *(((uint32_t *)old_ebp) + 1);
f01008bf:	8b 47 04             	mov    0x4(%edi),%eax
f01008c2:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        uint32_t args[5];
        struct Eipdebuginfo info;
        int i;
        while (ebp != 0x0) {
f01008c5:	e9 8d 00 00 00       	jmp    f0100957 <mon_backtrace+0xb9>
f01008ca:	b8 00 00 00 00       	mov    $0x0,%eax
            for (i = 0; i < 5; i++) 
                args[i] = *((uint32_t *) ebp + i + 2);                    
f01008cf:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01008d3:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
        uint32_t old_ret = *(((uint32_t *)old_ebp) + 1);
        uint32_t args[5];
        struct Eipdebuginfo info;
        int i;
        while (ebp != 0x0) {
            for (i = 0; i < 5; i++) 
f01008d7:	40                   	inc    %eax
f01008d8:	83 f8 05             	cmp    $0x5,%eax
f01008db:	75 f2                	jne    f01008cf <mon_backtrace+0x31>
                args[i] = *((uint32_t *) ebp + i + 2);                    
            debuginfo_eip(ret, &info);
f01008dd:	8d 55 bc             	lea    -0x44(%ebp),%edx
f01008e0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008e4:	89 34 24             	mov    %esi,(%esp)
f01008e7:	e8 7d 4d 00 00       	call   f0105669 <debuginfo_eip>
            cprintf("  ebp %x eip %x args %08x %08x %08x %08x %08x\n"  // no ,
f01008ec:	89 f0                	mov    %esi,%eax
f01008ee:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01008f1:	89 44 24 30          	mov    %eax,0x30(%esp)
f01008f5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01008f8:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f01008fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01008ff:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100903:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100906:	89 44 24 24          	mov    %eax,0x24(%esp)
f010090a:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010090d:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100911:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100914:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100918:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010091b:	89 44 24 18          	mov    %eax,0x18(%esp)
f010091f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100922:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100926:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100929:	89 44 24 10          	mov    %eax,0x10(%esp)
f010092d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100930:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100934:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010093c:	c7 04 24 fc 72 10 f0 	movl   $0xf01072fc,(%esp)
f0100943:	e8 ce 36 00 00       	call   f0104016 <cprintf>
                    ebp, ret, args[0], args[1], args[2], args[3], args[4],
                    info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (ret-info.eip_fn_addr)
                    );
        
            ebp = old_ebp;
            old_ebp = *(uint32_t *) ebp;
f0100948:	8b 07                	mov    (%edi),%eax
                    "         %s:%d: %.*s+%d\n",
                    ebp, ret, args[0], args[1], args[2], args[3], args[4],
                    info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (ret-info.eip_fn_addr)
                    );
        
            ebp = old_ebp;
f010094a:	89 fb                	mov    %edi,%ebx
            old_ebp = *(uint32_t *) ebp;
            ret = old_ret;
f010094c:	8b 75 b4             	mov    -0x4c(%ebp),%esi
            old_ret = *(((uint32_t *) old_ebp) + 1);                                                         
f010094f:	8b 50 04             	mov    0x4(%eax),%edx
f0100952:	89 55 b4             	mov    %edx,-0x4c(%ebp)
                    ebp, ret, args[0], args[1], args[2], args[3], args[4],
                    info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (ret-info.eip_fn_addr)
                    );
        
            ebp = old_ebp;
            old_ebp = *(uint32_t *) ebp;
f0100955:	89 c7                	mov    %eax,%edi
        uint32_t ret = *(((uint32_t *) ebp) + 1);
        uint32_t old_ret = *(((uint32_t *)old_ebp) + 1);
        uint32_t args[5];
        struct Eipdebuginfo info;
        int i;
        while (ebp != 0x0) {
f0100957:	85 db                	test   %ebx,%ebx
f0100959:	0f 85 6b ff ff ff    	jne    f01008ca <mon_backtrace+0x2c>
            old_ret = *(((uint32_t *) old_ebp) + 1);                                                         
        }

        
        return 0;
}
f010095f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100964:	81 c4 8c 00 00 00    	add    $0x8c,%esp
f010096a:	5b                   	pop    %ebx
f010096b:	5e                   	pop    %esi
f010096c:	5f                   	pop    %edi
f010096d:	5d                   	pop    %ebp
f010096e:	c3                   	ret    

f010096f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010096f:	55                   	push   %ebp
f0100970:	89 e5                	mov    %esp,%ebp
f0100972:	57                   	push   %edi
f0100973:	56                   	push   %esi
f0100974:	53                   	push   %ebx
f0100975:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100978:	c7 04 24 44 73 10 f0 	movl   $0xf0107344,(%esp)
f010097f:	e8 92 36 00 00       	call   f0104016 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100984:	c7 04 24 68 73 10 f0 	movl   $0xf0107368,(%esp)
f010098b:	e8 86 36 00 00       	call   f0104016 <cprintf>

	if (tf != NULL)
f0100990:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100994:	74 0b                	je     f01009a1 <monitor+0x32>
		print_trapframe(tf);
f0100996:	8b 45 08             	mov    0x8(%ebp),%eax
f0100999:	89 04 24             	mov    %eax,(%esp)
f010099c:	e8 97 3d 00 00       	call   f0104738 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01009a1:	c7 04 24 a4 71 10 f0 	movl   $0xf01071a4,(%esp)
f01009a8:	e8 87 55 00 00       	call   f0105f34 <readline>
f01009ad:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009af:	85 c0                	test   %eax,%eax
f01009b1:	74 ee                	je     f01009a1 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009b3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ba:	be 00 00 00 00       	mov    $0x0,%esi
f01009bf:	eb 04                	jmp    f01009c5 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009c1:	c6 03 00             	movb   $0x0,(%ebx)
f01009c4:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009c5:	8a 03                	mov    (%ebx),%al
f01009c7:	84 c0                	test   %al,%al
f01009c9:	74 5e                	je     f0100a29 <monitor+0xba>
f01009cb:	0f be c0             	movsbl %al,%eax
f01009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d2:	c7 04 24 a8 71 10 f0 	movl   $0xf01071a8,(%esp)
f01009d9:	e8 4b 57 00 00       	call   f0106129 <strchr>
f01009de:	85 c0                	test   %eax,%eax
f01009e0:	75 df                	jne    f01009c1 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01009e2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e5:	74 42                	je     f0100a29 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009e7:	83 fe 0f             	cmp    $0xf,%esi
f01009ea:	75 16                	jne    f0100a02 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ec:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01009f3:	00 
f01009f4:	c7 04 24 ad 71 10 f0 	movl   $0xf01071ad,(%esp)
f01009fb:	e8 16 36 00 00       	call   f0104016 <cprintf>
f0100a00:	eb 9f                	jmp    f01009a1 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a02:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a06:	46                   	inc    %esi
f0100a07:	eb 01                	jmp    f0100a0a <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a09:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a0a:	8a 03                	mov    (%ebx),%al
f0100a0c:	84 c0                	test   %al,%al
f0100a0e:	74 b5                	je     f01009c5 <monitor+0x56>
f0100a10:	0f be c0             	movsbl %al,%eax
f0100a13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a17:	c7 04 24 a8 71 10 f0 	movl   $0xf01071a8,(%esp)
f0100a1e:	e8 06 57 00 00       	call   f0106129 <strchr>
f0100a23:	85 c0                	test   %eax,%eax
f0100a25:	74 e2                	je     f0100a09 <monitor+0x9a>
f0100a27:	eb 9c                	jmp    f01009c5 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100a29:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a30:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a31:	85 f6                	test   %esi,%esi
f0100a33:	0f 84 68 ff ff ff    	je     f01009a1 <monitor+0x32>
f0100a39:	bb c0 73 10 f0       	mov    $0xf01073c0,%ebx
f0100a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a43:	8b 03                	mov    (%ebx),%eax
f0100a45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a49:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a4c:	89 04 24             	mov    %eax,(%esp)
f0100a4f:	e8 82 56 00 00       	call   f01060d6 <strcmp>
f0100a54:	85 c0                	test   %eax,%eax
f0100a56:	75 24                	jne    f0100a7c <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100a58:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a5b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a5e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a62:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a65:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a69:	89 34 24             	mov    %esi,(%esp)
f0100a6c:	ff 14 85 c8 73 10 f0 	call   *-0xfef8c38(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a73:	85 c0                	test   %eax,%eax
f0100a75:	78 26                	js     f0100a9d <monitor+0x12e>
f0100a77:	e9 25 ff ff ff       	jmp    f01009a1 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a7c:	47                   	inc    %edi
f0100a7d:	83 c3 0c             	add    $0xc,%ebx
f0100a80:	83 ff 03             	cmp    $0x3,%edi
f0100a83:	75 be                	jne    f0100a43 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a85:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a8c:	c7 04 24 ca 71 10 f0 	movl   $0xf01071ca,(%esp)
f0100a93:	e8 7e 35 00 00       	call   f0104016 <cprintf>
f0100a98:	e9 04 ff ff ff       	jmp    f01009a1 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a9d:	83 c4 5c             	add    $0x5c,%esp
f0100aa0:	5b                   	pop    %ebx
f0100aa1:	5e                   	pop    %esi
f0100aa2:	5f                   	pop    %edi
f0100aa3:	5d                   	pop    %ebp
f0100aa4:	c3                   	ret    
f0100aa5:	00 00                	add    %al,(%eax)
	...

f0100aa8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aab:	83 3d 3c 12 33 f0 00 	cmpl   $0x0,0xf033123c
f0100ab2:	75 11                	jne    f0100ac5 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab4:	ba 07 40 37 f0       	mov    $0xf0374007,%edx
f0100ab9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100abf:	89 15 3c 12 33 f0    	mov    %edx,0xf033123c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        if(n>0){
f0100ac5:	85 c0                	test   %eax,%eax
f0100ac7:	74 19                	je     f0100ae2 <boot_alloc+0x3a>
            result = nextfree;
f0100ac9:	8b 15 3c 12 33 f0    	mov    0xf033123c,%edx
            nextfree += n;
            nextfree = ROUNDUP((char *) nextfree, PGSIZE);
f0100acf:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100ad6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100adb:	a3 3c 12 33 f0       	mov    %eax,0xf033123c
            return result;
f0100ae0:	eb 06                	jmp    f0100ae8 <boot_alloc+0x40>
        }
        else{   // n == 0
            return  nextfree;
f0100ae2:	8b 15 3c 12 33 f0    	mov    0xf033123c,%edx
        }
	return NULL;
}
f0100ae8:	89 d0                	mov    %edx,%eax
f0100aea:	5d                   	pop    %ebp
f0100aeb:	c3                   	ret    

f0100aec <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100aec:	55                   	push   %ebp
f0100aed:	89 e5                	mov    %esp,%ebp
f0100aef:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100af2:	89 d1                	mov    %edx,%ecx
f0100af4:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100af7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100afa:	a8 01                	test   $0x1,%al
f0100afc:	74 4d                	je     f0100b4b <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100afe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b03:	89 c1                	mov    %eax,%ecx
f0100b05:	c1 e9 0c             	shr    $0xc,%ecx
f0100b08:	3b 0d 88 1e 33 f0    	cmp    0xf0331e88,%ecx
f0100b0e:	72 20                	jb     f0100b30 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b10:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b14:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0100b1b:	f0 
f0100b1c:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0100b23:	00 
f0100b24:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100b2b:	e8 10 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b30:	c1 ea 0c             	shr    $0xc,%edx
f0100b33:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b39:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b40:	a8 01                	test   $0x1,%al
f0100b42:	74 0e                	je     f0100b52 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b49:	eb 0c                	jmp    f0100b57 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b50:	eb 05                	jmp    f0100b57 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100b52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b57:	c9                   	leave  
f0100b58:	c3                   	ret    

f0100b59 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b59:	55                   	push   %ebp
f0100b5a:	89 e5                	mov    %esp,%ebp
f0100b5c:	56                   	push   %esi
f0100b5d:	53                   	push   %ebx
f0100b5e:	83 ec 10             	sub    $0x10,%esp
f0100b61:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b63:	89 04 24             	mov    %eax,(%esp)
f0100b66:	e8 65 33 00 00       	call   f0103ed0 <mc146818_read>
f0100b6b:	89 c6                	mov    %eax,%esi
f0100b6d:	43                   	inc    %ebx
f0100b6e:	89 1c 24             	mov    %ebx,(%esp)
f0100b71:	e8 5a 33 00 00       	call   f0103ed0 <mc146818_read>
f0100b76:	c1 e0 08             	shl    $0x8,%eax
f0100b79:	09 f0                	or     %esi,%eax
}
f0100b7b:	83 c4 10             	add    $0x10,%esp
f0100b7e:	5b                   	pop    %ebx
f0100b7f:	5e                   	pop    %esi
f0100b80:	5d                   	pop    %ebp
f0100b81:	c3                   	ret    

f0100b82 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b82:	55                   	push   %ebp
f0100b83:	89 e5                	mov    %esp,%ebp
f0100b85:	57                   	push   %edi
f0100b86:	56                   	push   %esi
f0100b87:	53                   	push   %ebx
f0100b88:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8b:	3c 01                	cmp    $0x1,%al
f0100b8d:	19 f6                	sbb    %esi,%esi
f0100b8f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b95:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b96:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0100b9c:	85 d2                	test   %edx,%edx
f0100b9e:	75 1c                	jne    f0100bbc <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100ba0:	c7 44 24 08 e4 73 10 	movl   $0xf01073e4,0x8(%esp)
f0100ba7:	f0 
f0100ba8:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0100baf:	00 
f0100bb0:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100bb7:	e8 84 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100bbc:	84 c0                	test   %al,%al
f0100bbe:	74 4b                	je     f0100c0b <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bc0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100bc3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100bc9:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bcc:	89 d0                	mov    %edx,%eax
f0100bce:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100bd4:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bd7:	c1 e8 16             	shr    $0x16,%eax
f0100bda:	39 c6                	cmp    %eax,%esi
f0100bdc:	0f 96 c0             	setbe  %al
f0100bdf:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100be2:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100be6:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100be8:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bec:	8b 12                	mov    (%edx),%edx
f0100bee:	85 d2                	test   %edx,%edx
f0100bf0:	75 da                	jne    f0100bcc <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bf2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bf5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bfb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c01:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c06:	a3 40 12 33 f0       	mov    %eax,0xf0331240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c0b:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
f0100c11:	eb 63                	jmp    f0100c76 <check_page_free_list+0xf4>
f0100c13:	89 d8                	mov    %ebx,%eax
f0100c15:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100c1b:	c1 f8 03             	sar    $0x3,%eax
f0100c1e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c21:	89 c2                	mov    %eax,%edx
f0100c23:	c1 ea 16             	shr    $0x16,%edx
f0100c26:	39 d6                	cmp    %edx,%esi
f0100c28:	76 4a                	jbe    f0100c74 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c2a:	89 c2                	mov    %eax,%edx
f0100c2c:	c1 ea 0c             	shr    $0xc,%edx
f0100c2f:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100c35:	72 20                	jb     f0100c57 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c3b:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0100c42:	f0 
f0100c43:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c4a:	00 
f0100c4b:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0100c52:	e8 e9 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c57:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c5e:	00 
f0100c5f:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c66:	00 
	return (void *)(pa + KERNBASE);
f0100c67:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c6c:	89 04 24             	mov    %eax,(%esp)
f0100c6f:	e8 ea 54 00 00       	call   f010615e <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c74:	8b 1b                	mov    (%ebx),%ebx
f0100c76:	85 db                	test   %ebx,%ebx
f0100c78:	75 99                	jne    f0100c13 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c7f:	e8 24 fe ff ff       	call   f0100aa8 <boot_alloc>
f0100c84:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c87:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c8d:	8b 0d 90 1e 33 f0    	mov    0xf0331e90,%ecx
		assert(pp < pages + npages);
f0100c93:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f0100c98:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c9b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ca1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ca4:	be 00 00 00 00       	mov    $0x0,%esi
f0100ca9:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cac:	e9 c4 01 00 00       	jmp    f0100e75 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cb1:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100cb4:	73 24                	jae    f0100cda <check_page_free_list+0x158>
f0100cb6:	c7 44 24 0c 1b 7d 10 	movl   $0xf0107d1b,0xc(%esp)
f0100cbd:	f0 
f0100cbe:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100cc5:	f0 
f0100cc6:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0100ccd:	00 
f0100cce:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100cd5:	e8 66 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cda:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cdd:	72 24                	jb     f0100d03 <check_page_free_list+0x181>
f0100cdf:	c7 44 24 0c 3c 7d 10 	movl   $0xf0107d3c,0xc(%esp)
f0100ce6:	f0 
f0100ce7:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100cee:	f0 
f0100cef:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0100cf6:	00 
f0100cf7:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100cfe:	e8 3d f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d03:	89 d0                	mov    %edx,%eax
f0100d05:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d08:	a8 07                	test   $0x7,%al
f0100d0a:	74 24                	je     f0100d30 <check_page_free_list+0x1ae>
f0100d0c:	c7 44 24 0c 08 74 10 	movl   $0xf0107408,0xc(%esp)
f0100d13:	f0 
f0100d14:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100d1b:	f0 
f0100d1c:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0100d23:	00 
f0100d24:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100d2b:	e8 10 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d30:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d33:	c1 e0 0c             	shl    $0xc,%eax
f0100d36:	75 24                	jne    f0100d5c <check_page_free_list+0x1da>
f0100d38:	c7 44 24 0c 50 7d 10 	movl   $0xf0107d50,0xc(%esp)
f0100d3f:	f0 
f0100d40:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100d47:	f0 
f0100d48:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0100d4f:	00 
f0100d50:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100d57:	e8 e4 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d5c:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d61:	75 24                	jne    f0100d87 <check_page_free_list+0x205>
f0100d63:	c7 44 24 0c 61 7d 10 	movl   $0xf0107d61,0xc(%esp)
f0100d6a:	f0 
f0100d6b:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100d72:	f0 
f0100d73:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0100d7a:	00 
f0100d7b:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100d82:	e8 b9 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d87:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d8c:	75 24                	jne    f0100db2 <check_page_free_list+0x230>
f0100d8e:	c7 44 24 0c 3c 74 10 	movl   $0xf010743c,0xc(%esp)
f0100d95:	f0 
f0100d96:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100d9d:	f0 
f0100d9e:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0100da5:	00 
f0100da6:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100dad:	e8 8e f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100db2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100db7:	75 24                	jne    f0100ddd <check_page_free_list+0x25b>
f0100db9:	c7 44 24 0c 7a 7d 10 	movl   $0xf0107d7a,0xc(%esp)
f0100dc0:	f0 
f0100dc1:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100dc8:	f0 
f0100dc9:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0100dd0:	00 
f0100dd1:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100dd8:	e8 63 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ddd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100de2:	76 59                	jbe    f0100e3d <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100de4:	89 c1                	mov    %eax,%ecx
f0100de6:	c1 e9 0c             	shr    $0xc,%ecx
f0100de9:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100dec:	77 20                	ja     f0100e0e <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100df2:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0100df9:	f0 
f0100dfa:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e01:	00 
f0100e02:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0100e09:	e8 32 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e0e:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e14:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e17:	76 24                	jbe    f0100e3d <check_page_free_list+0x2bb>
f0100e19:	c7 44 24 0c 60 74 10 	movl   $0xf0107460,0xc(%esp)
f0100e20:	f0 
f0100e21:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100e28:	f0 
f0100e29:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100e30:	00 
f0100e31:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100e38:	e8 03 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e3d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e42:	75 24                	jne    f0100e68 <check_page_free_list+0x2e6>
f0100e44:	c7 44 24 0c 94 7d 10 	movl   $0xf0107d94,0xc(%esp)
f0100e4b:	f0 
f0100e4c:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100e53:	f0 
f0100e54:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0100e5b:	00 
f0100e5c:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100e63:	e8 d8 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100e68:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e6d:	77 03                	ja     f0100e72 <check_page_free_list+0x2f0>
			++nfree_basemem;
f0100e6f:	46                   	inc    %esi
f0100e70:	eb 01                	jmp    f0100e73 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0100e72:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e73:	8b 12                	mov    (%edx),%edx
f0100e75:	85 d2                	test   %edx,%edx
f0100e77:	0f 85 34 fe ff ff    	jne    f0100cb1 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e7d:	85 f6                	test   %esi,%esi
f0100e7f:	7f 24                	jg     f0100ea5 <check_page_free_list+0x323>
f0100e81:	c7 44 24 0c b1 7d 10 	movl   $0xf0107db1,0xc(%esp)
f0100e88:	f0 
f0100e89:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100e90:	f0 
f0100e91:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0100e98:	00 
f0100e99:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100ea0:	e8 9b f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100ea5:	85 db                	test   %ebx,%ebx
f0100ea7:	7f 24                	jg     f0100ecd <check_page_free_list+0x34b>
f0100ea9:	c7 44 24 0c c3 7d 10 	movl   $0xf0107dc3,0xc(%esp)
f0100eb0:	f0 
f0100eb1:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0100eb8:	f0 
f0100eb9:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0100ec0:	00 
f0100ec1:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0100ec8:	e8 73 f1 ff ff       	call   f0100040 <_panic>
}
f0100ecd:	83 c4 4c             	add    $0x4c,%esp
f0100ed0:	5b                   	pop    %ebx
f0100ed1:	5e                   	pop    %esi
f0100ed2:	5f                   	pop    %edi
f0100ed3:	5d                   	pop    %ebp
f0100ed4:	c3                   	ret    

f0100ed5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ed5:	55                   	push   %ebp
f0100ed6:	89 e5                	mov    %esp,%ebp
f0100ed8:	56                   	push   %esi
f0100ed9:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100eda:	be 00 00 00 00       	mov    $0x0,%esi
f0100edf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ee4:	e9 c4 00 00 00       	jmp    f0100fad <page_init+0xd8>
            if(i == 0){
f0100ee9:	85 db                	test   %ebx,%ebx
f0100eeb:	75 16                	jne    f0100f03 <page_init+0x2e>
                pages[i].pp_ref = 1;
f0100eed:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
f0100ef2:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                pages[i].pp_link = NULL;
f0100ef8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
                continue;
f0100efe:	e9 a6 00 00 00       	jmp    f0100fa9 <page_init+0xd4>
            }
            else if(i == MPENTRY_PADDR/PGSIZE){
f0100f03:	83 fb 07             	cmp    $0x7,%ebx
f0100f06:	0f 84 9d 00 00 00    	je     f0100fa9 <page_init+0xd4>
                continue;
            }
            else if(i < npages_basemem){
f0100f0c:	3b 1d 38 12 33 f0    	cmp    0xf0331238,%ebx
f0100f12:	73 25                	jae    f0100f39 <page_init+0x64>
                pages[i].pp_ref = 0;
f0100f14:	89 f0                	mov    %esi,%eax
f0100f16:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100f1c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
                pages[i].pp_link = page_free_list;
f0100f22:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0100f28:	89 10                	mov    %edx,(%eax)
                page_free_list = &pages[i];
f0100f2a:	89 f0                	mov    %esi,%eax
f0100f2c:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100f32:	a3 40 12 33 f0       	mov    %eax,0xf0331240
f0100f37:	eb 70                	jmp    f0100fa9 <page_init+0xd4>
            }
            else if(i>=(IOPHYSMEM/PGSIZE) && (i<(EXTPHYSMEM/PGSIZE))){
f0100f39:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100f3f:	83 f8 5f             	cmp    $0x5f,%eax
f0100f42:	77 16                	ja     f0100f5a <page_init+0x85>
                pages[i].pp_ref = 1;
f0100f44:	89 f0                	mov    %esi,%eax
f0100f46:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100f4c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                pages[i].pp_link = NULL;
f0100f52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f58:	eb 4f                	jmp    f0100fa9 <page_init+0xd4>
            }
            else{   //i>=EXTPTHYSMEM/PGSIZE
                if(i < ((int)(boot_alloc(0))-KERNBASE)/PGSIZE){
f0100f5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5f:	e8 44 fb ff ff       	call   f0100aa8 <boot_alloc>
f0100f64:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f69:	c1 e8 0c             	shr    $0xc,%eax
f0100f6c:	39 c3                	cmp    %eax,%ebx
f0100f6e:	73 16                	jae    f0100f86 <page_init+0xb1>
                    pages[i].pp_ref = 1;
f0100f70:	89 f0                	mov    %esi,%eax
f0100f72:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100f78:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
                    pages[i].pp_link = NULL;
f0100f7e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100f84:	eb 23                	jmp    f0100fa9 <page_init+0xd4>
                }
                else{
		    pages[i].pp_ref = 0;
f0100f86:	89 f0                	mov    %esi,%eax
f0100f88:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100f8e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		    pages[i].pp_link = page_free_list;
f0100f94:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0100f9a:	89 10                	mov    %edx,(%eax)
		    page_free_list = &pages[i];
f0100f9c:	89 f0                	mov    %esi,%eax
f0100f9e:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100fa4:	a3 40 12 33 f0       	mov    %eax,0xf0331240
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100fa9:	43                   	inc    %ebx
f0100faa:	83 c6 08             	add    $0x8,%esi
f0100fad:	3b 1d 88 1e 33 f0    	cmp    0xf0331e88,%ebx
f0100fb3:	0f 82 30 ff ff ff    	jb     f0100ee9 <page_init+0x14>
		    pages[i].pp_link = page_free_list;
		    page_free_list = &pages[i];
                }
	    }
        }
}
f0100fb9:	5b                   	pop    %ebx
f0100fba:	5e                   	pop    %esi
f0100fbb:	5d                   	pop    %ebp
f0100fbc:	c3                   	ret    

f0100fbd <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	53                   	push   %ebx
f0100fc1:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
        //cprintf("page_alloc\n");
        if(!page_free_list){
f0100fc4:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
f0100fca:	85 db                	test   %ebx,%ebx
f0100fcc:	74 6b                	je     f0101039 <page_alloc+0x7c>
            return NULL;
        }
        struct PageInfo * pagep = page_free_list;
        page_free_list = pagep->pp_link;
f0100fce:	8b 03                	mov    (%ebx),%eax
f0100fd0:	a3 40 12 33 f0       	mov    %eax,0xf0331240
        pagep->pp_link = NULL;
f0100fd5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        if(alloc_flags & ALLOC_ZERO){
f0100fdb:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fdf:	74 58                	je     f0101039 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fe1:	89 d8                	mov    %ebx,%eax
f0100fe3:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100fe9:	c1 f8 03             	sar    $0x3,%eax
f0100fec:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fef:	89 c2                	mov    %eax,%edx
f0100ff1:	c1 ea 0c             	shr    $0xc,%edx
f0100ff4:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100ffa:	72 20                	jb     f010101c <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ffc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101000:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0101007:	f0 
f0101008:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010100f:	00 
f0101010:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0101017:	e8 24 f0 ff ff       	call   f0100040 <_panic>
            memset(page2kva(pagep), 0, PGSIZE);
f010101c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101023:	00 
f0101024:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010102b:	00 
	return (void *)(pa + KERNBASE);
f010102c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101031:	89 04 24             	mov    %eax,(%esp)
f0101034:	e8 25 51 00 00       	call   f010615e <memset>
        }
        // cprintf("number of page:%d\n",++count_page);
	return pagep;
}
f0101039:	89 d8                	mov    %ebx,%eax
f010103b:	83 c4 14             	add    $0x14,%esp
f010103e:	5b                   	pop    %ebx
f010103f:	5d                   	pop    %ebp
f0101040:	c3                   	ret    

f0101041 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101041:	55                   	push   %ebp
f0101042:	89 e5                	mov    %esp,%ebp
f0101044:	83 ec 18             	sub    $0x18,%esp
f0101047:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
        
        if(pp->pp_ref != 0 || pp->pp_link != NULL)
f010104a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010104f:	75 05                	jne    f0101056 <page_free+0x15>
f0101051:	83 38 00             	cmpl   $0x0,(%eax)
f0101054:	74 1c                	je     f0101072 <page_free+0x31>
            panic("Panic at page_free!\n");
f0101056:	c7 44 24 08 d4 7d 10 	movl   $0xf0107dd4,0x8(%esp)
f010105d:	f0 
f010105e:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
f0101065:	00 
f0101066:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010106d:	e8 ce ef ff ff       	call   f0100040 <_panic>
        else{
            pp->pp_link = page_free_list;
f0101072:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0101078:	89 10                	mov    %edx,(%eax)
            page_free_list = pp;
f010107a:	a3 40 12 33 f0       	mov    %eax,0xf0331240
            // cprintf("number of page:%d\n",--count_page);
            return;
        }
}
f010107f:	c9                   	leave  
f0101080:	c3                   	ret    

f0101081 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101081:	55                   	push   %ebp
f0101082:	89 e5                	mov    %esp,%ebp
f0101084:	83 ec 18             	sub    $0x18,%esp
f0101087:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010108a:	8b 50 04             	mov    0x4(%eax),%edx
f010108d:	4a                   	dec    %edx
f010108e:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101092:	66 85 d2             	test   %dx,%dx
f0101095:	75 08                	jne    f010109f <page_decref+0x1e>
		page_free(pp);
f0101097:	89 04 24             	mov    %eax,(%esp)
f010109a:	e8 a2 ff ff ff       	call   f0101041 <page_free>
}
f010109f:	c9                   	leave  
f01010a0:	c3                   	ret    

f01010a1 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010a1:	55                   	push   %ebp
f01010a2:	89 e5                	mov    %esp,%ebp
f01010a4:	56                   	push   %esi
f01010a5:	53                   	push   %ebx
f01010a6:	83 ec 10             	sub    $0x10,%esp
f01010a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
        //cprintf("pgdir_walk,create:%d\n",create);
        pte_t*  ptpp = NULL; // a point to page table page
        if(pgdir[PDX(va)] == 0){    // not exist
f01010ac:	89 f3                	mov    %esi,%ebx
f01010ae:	c1 eb 16             	shr    $0x16,%ebx
f01010b1:	c1 e3 02             	shl    $0x2,%ebx
f01010b4:	03 5d 08             	add    0x8(%ebp),%ebx
f01010b7:	8b 03                	mov    (%ebx),%eax
f01010b9:	85 c0                	test   %eax,%eax
f01010bb:	75 75                	jne    f0101132 <pgdir_walk+0x91>
             if(create == 0){
f01010bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010c1:	0f 84 d0 00 00 00    	je     f0101197 <pgdir_walk+0xf6>
                 return NULL;
             }
             else{ 
                struct PageInfo* pagep = page_alloc(1);
f01010c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010ce:	e8 ea fe ff ff       	call   f0100fbd <page_alloc>
                // cprintf("page_free_list in walk:%08x\n",page_free_list);
                if(pagep == NULL)   //alloc fail
f01010d3:	85 c0                	test   %eax,%eax
f01010d5:	0f 84 c3 00 00 00    	je     f010119e <pgdir_walk+0xfd>
                    return NULL;
                else{
                    pagep->pp_ref++;
f01010db:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010df:	89 c2                	mov    %eax,%edx
f01010e1:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01010e7:	c1 fa 03             	sar    $0x3,%edx
f01010ea:	c1 e2 0c             	shl    $0xc,%edx
                    pgdir[PDX(va)] = page2pa(pagep) | PTE_P | PTE_W | PTE_U;
f01010ed:	83 ca 07             	or     $0x7,%edx
f01010f0:	89 13                	mov    %edx,(%ebx)
f01010f2:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01010f8:	c1 f8 03             	sar    $0x3,%eax
f01010fb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010fe:	89 c2                	mov    %eax,%edx
f0101100:	c1 ea 0c             	shr    $0xc,%edx
f0101103:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0101109:	72 20                	jb     f010112b <pgdir_walk+0x8a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010110b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010110f:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0101116:	f0 
f0101117:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010111e:	00 
f010111f:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0101126:	e8 15 ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010112b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101130:	eb 58                	jmp    f010118a <pgdir_walk+0xe9>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101132:	c1 e8 0c             	shr    $0xc,%eax
f0101135:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f010113b:	39 d0                	cmp    %edx,%eax
f010113d:	72 1c                	jb     f010115b <pgdir_walk+0xba>
		panic("pa2page called with invalid pa");
f010113f:	c7 44 24 08 a8 74 10 	movl   $0xf01074a8,0x8(%esp)
f0101146:	f0 
f0101147:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010114e:	00 
f010114f:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0101156:	e8 e5 ee ff ff       	call   f0100040 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010115b:	89 c1                	mov    %eax,%ecx
f010115d:	c1 e1 0c             	shl    $0xc,%ecx
f0101160:	39 d0                	cmp    %edx,%eax
f0101162:	72 20                	jb     f0101184 <pgdir_walk+0xe3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101164:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101168:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f010116f:	f0 
f0101170:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101177:	00 
f0101178:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f010117f:	e8 bc ee ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101184:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
             }
        }
        else{
            ptpp = page2kva(pa2page(PTE_ADDR(pgdir[PDX(va)])));   
        }
	return &ptpp[PTX(va)];
f010118a:	c1 ee 0a             	shr    $0xa,%esi
f010118d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101193:	01 f0                	add    %esi,%eax
f0101195:	eb 0c                	jmp    f01011a3 <pgdir_walk+0x102>
	// Fill this function in
        //cprintf("pgdir_walk,create:%d\n",create);
        pte_t*  ptpp = NULL; // a point to page table page
        if(pgdir[PDX(va)] == 0){    // not exist
             if(create == 0){
                 return NULL;
f0101197:	b8 00 00 00 00       	mov    $0x0,%eax
f010119c:	eb 05                	jmp    f01011a3 <pgdir_walk+0x102>
             }
             else{ 
                struct PageInfo* pagep = page_alloc(1);
                // cprintf("page_free_list in walk:%08x\n",page_free_list);
                if(pagep == NULL)   //alloc fail
                    return NULL;
f010119e:	b8 00 00 00 00       	mov    $0x0,%eax
        }
        else{
            ptpp = page2kva(pa2page(PTE_ADDR(pgdir[PDX(va)])));   
        }
	return &ptpp[PTX(va)];
}
f01011a3:	83 c4 10             	add    $0x10,%esp
f01011a6:	5b                   	pop    %ebx
f01011a7:	5e                   	pop    %esi
f01011a8:	5d                   	pop    %ebp
f01011a9:	c3                   	ret    

f01011aa <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011aa:	55                   	push   %ebp
f01011ab:	89 e5                	mov    %esp,%ebp
f01011ad:	57                   	push   %edi
f01011ae:	56                   	push   %esi
f01011af:	53                   	push   %ebx
f01011b0:	83 ec 2c             	sub    $0x2c,%esp
f01011b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        pte_t* ptpp = NULL;
        uintptr_t temp_va = va;
        physaddr_t temp_pa = pa;
        int i;
        
        for(i = 0;i < size/PGSIZE;i++){
f01011b6:	c1 e9 0c             	shr    $0xc,%ecx
f01011b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
{
	// Fill this function in 
        // cprintf("boot_map_region\n");
        pte_t* ptpp = NULL;
        uintptr_t temp_va = va;
        physaddr_t temp_pa = pa;
f01011bc:	8b 7d 08             	mov    0x8(%ebp),%edi
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in 
        // cprintf("boot_map_region\n");
        pte_t* ptpp = NULL;
        uintptr_t temp_va = va;
f01011bf:	89 d3                	mov    %edx,%ebx
        physaddr_t temp_pa = pa;
        int i;
        
        for(i = 0;i < size/PGSIZE;i++){
f01011c1:	be 00 00 00 00       	mov    $0x0,%esi
            ptpp = pgdir_walk(pgdir,(void *)temp_va,1);
            if(ptpp == NULL)
                return ;
            else{
                *ptpp = temp_pa | perm | PTE_P;
f01011c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c9:	83 c8 01             	or     $0x1,%eax
f01011cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        pte_t* ptpp = NULL;
        uintptr_t temp_va = va;
        physaddr_t temp_pa = pa;
        int i;
        
        for(i = 0;i < size/PGSIZE;i++){
f01011cf:	eb 2f                	jmp    f0101200 <boot_map_region+0x56>
            ptpp = pgdir_walk(pgdir,(void *)temp_va,1);
f01011d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011d8:	00 
f01011d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011e0:	89 04 24             	mov    %eax,(%esp)
f01011e3:	e8 b9 fe ff ff       	call   f01010a1 <pgdir_walk>
            if(ptpp == NULL)
f01011e8:	85 c0                	test   %eax,%eax
f01011ea:	74 19                	je     f0101205 <boot_map_region+0x5b>
                return ;
            else{
                *ptpp = temp_pa | perm | PTE_P;
f01011ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011ef:	09 fa                	or     %edi,%edx
f01011f1:	89 10                	mov    %edx,(%eax)
                temp_pa += PGSIZE;
f01011f3:	81 c7 00 10 00 00    	add    $0x1000,%edi
                temp_va += PGSIZE;
f01011f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
        pte_t* ptpp = NULL;
        uintptr_t temp_va = va;
        physaddr_t temp_pa = pa;
        int i;
        
        for(i = 0;i < size/PGSIZE;i++){
f01011ff:	46                   	inc    %esi
f0101200:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101203:	75 cc                	jne    f01011d1 <boot_map_region+0x27>
                temp_pa += PGSIZE;
                temp_va += PGSIZE;
            }
        }  
        return;
}
f0101205:	83 c4 2c             	add    $0x2c,%esp
f0101208:	5b                   	pop    %ebx
f0101209:	5e                   	pop    %esi
f010120a:	5f                   	pop    %edi
f010120b:	5d                   	pop    %ebp
f010120c:	c3                   	ret    

f010120d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010120d:	55                   	push   %ebp
f010120e:	89 e5                	mov    %esp,%ebp
f0101210:	53                   	push   %ebx
f0101211:	83 ec 14             	sub    $0x14,%esp
f0101214:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
        //cprintf("page_lookup\n"); 
        pte_t* ptpp = pgdir_walk(pgdir,(void*)va,0);    
f0101217:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010121e:	00 
f010121f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101222:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101226:	8b 45 08             	mov    0x8(%ebp),%eax
f0101229:	89 04 24             	mov    %eax,(%esp)
f010122c:	e8 70 fe ff ff       	call   f01010a1 <pgdir_walk>
        if(ptpp == NULL)        // no page mapped at va
f0101231:	85 c0                	test   %eax,%eax
f0101233:	74 3a                	je     f010126f <page_lookup+0x62>
            return NULL;
        else{
            if(pte_store != NULL){
f0101235:	85 db                	test   %ebx,%ebx
f0101237:	74 02                	je     f010123b <page_lookup+0x2e>
                *pte_store = ptpp;
f0101239:	89 03                	mov    %eax,(%ebx)
            }
            return pa2page(PTE_ADDR(*ptpp));
f010123b:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010123d:	c1 e8 0c             	shr    $0xc,%eax
f0101240:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0101246:	72 1c                	jb     f0101264 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101248:	c7 44 24 08 a8 74 10 	movl   $0xf01074a8,0x8(%esp)
f010124f:	f0 
f0101250:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101257:	00 
f0101258:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f010125f:	e8 dc ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101264:	c1 e0 03             	shl    $0x3,%eax
f0101267:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f010126d:	eb 05                	jmp    f0101274 <page_lookup+0x67>
{
	// Fill this function in
        //cprintf("page_lookup\n"); 
        pte_t* ptpp = pgdir_walk(pgdir,(void*)va,0);    
        if(ptpp == NULL)        // no page mapped at va
            return NULL;
f010126f:	b8 00 00 00 00       	mov    $0x0,%eax
            if(pte_store != NULL){
                *pte_store = ptpp;
            }
            return pa2page(PTE_ADDR(*ptpp));
        }
}
f0101274:	83 c4 14             	add    $0x14,%esp
f0101277:	5b                   	pop    %ebx
f0101278:	5d                   	pop    %ebp
f0101279:	c3                   	ret    

f010127a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010127a:	55                   	push   %ebp
f010127b:	89 e5                	mov    %esp,%ebp
f010127d:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101280:	e8 07 55 00 00       	call   f010678c <cpunum>
f0101285:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010128c:	29 c2                	sub    %eax,%edx
f010128e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101291:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0101298:	00 
f0101299:	74 20                	je     f01012bb <tlb_invalidate+0x41>
f010129b:	e8 ec 54 00 00       	call   f010678c <cpunum>
f01012a0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01012a7:	29 c2                	sub    %eax,%edx
f01012a9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01012ac:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01012b3:	8b 55 08             	mov    0x8(%ebp),%edx
f01012b6:	39 50 60             	cmp    %edx,0x60(%eax)
f01012b9:	75 06                	jne    f01012c1 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012be:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01012c1:	c9                   	leave  
f01012c2:	c3                   	ret    

f01012c3 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01012c3:	55                   	push   %ebp
f01012c4:	89 e5                	mov    %esp,%ebp
f01012c6:	56                   	push   %esi
f01012c7:	53                   	push   %ebx
f01012c8:	83 ec 20             	sub    $0x20,%esp
f01012cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01012ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        // cprintf("page_remove\n");  
        pte_t* ptpp = pgdir_walk(pgdir,(void*)va,0);
f01012d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012d8:	00 
f01012d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012dd:	89 34 24             	mov    %esi,(%esp)
f01012e0:	e8 bc fd ff ff       	call   f01010a1 <pgdir_walk>
f01012e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        pte_t ** pte_store = &ptpp;
f01012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012eb:	89 44 24 08          	mov    %eax,0x8(%esp)
        struct PageInfo* pagep = page_lookup(pgdir,(void*)va,pte_store);
f01012ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012f3:	89 34 24             	mov    %esi,(%esp)
f01012f6:	e8 12 ff ff ff       	call   f010120d <page_lookup>
        if(pagep == NULL)
f01012fb:	85 c0                	test   %eax,%eax
f01012fd:	74 2a                	je     f0101329 <page_remove+0x66>
            return ;
        else{
            pagep->pp_ref--;
f01012ff:	8b 50 04             	mov    0x4(%eax),%edx
f0101302:	4a                   	dec    %edx
f0101303:	66 89 50 04          	mov    %dx,0x4(%eax)
            if(pagep->pp_ref == 0)
f0101307:	66 85 d2             	test   %dx,%dx
f010130a:	75 08                	jne    f0101314 <page_remove+0x51>
                page_free(pagep);
f010130c:	89 04 24             	mov    %eax,(%esp)
f010130f:	e8 2d fd ff ff       	call   f0101041 <page_free>
            *ptpp = 0;
f0101314:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101317:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            tlb_invalidate(pgdir,va);
f010131d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101321:	89 34 24             	mov    %esi,(%esp)
f0101324:	e8 51 ff ff ff       	call   f010127a <tlb_invalidate>
        }
}
f0101329:	83 c4 20             	add    $0x20,%esp
f010132c:	5b                   	pop    %ebx
f010132d:	5e                   	pop    %esi
f010132e:	5d                   	pop    %ebp
f010132f:	c3                   	ret    

f0101330 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101330:	55                   	push   %ebp
f0101331:	89 e5                	mov    %esp,%ebp
f0101333:	57                   	push   %edi
f0101334:	56                   	push   %esi
f0101335:	53                   	push   %ebx
f0101336:	83 ec 1c             	sub    $0x1c,%esp
f0101339:	8b 7d 08             	mov    0x8(%ebp),%edi
f010133c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
        
        // cprintf("pgdir_insert\n");
        pte_t *entry = NULL;
        entry = pgdir_walk(pgdir, va, 1);    //通过pgdir_walk函数求出va对应的页表项
f010133f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101346:	00 
f0101347:	8b 45 10             	mov    0x10(%ebp),%eax
f010134a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010134e:	89 3c 24             	mov    %edi,(%esp)
f0101351:	e8 4b fd ff ff       	call   f01010a1 <pgdir_walk>
f0101356:	89 c6                	mov    %eax,%esi
        if(entry == NULL) 
f0101358:	85 c0                	test   %eax,%eax
f010135a:	74 50                	je     f01013ac <page_insert+0x7c>
            return -E_NO_MEM;
        pp->pp_ref++;                   //修改引用计数值
f010135c:	66 ff 43 04          	incw   0x4(%ebx)
        if((*entry) & PTE_P)        //如果这个虚拟地址已有物理页与之映射
f0101360:	f6 00 01             	testb  $0x1,(%eax)
f0101363:	74 1e                	je     f0101383 <page_insert+0x53>
        {
            tlb_invalidate(pgdir, va);//TLB无效
f0101365:	8b 55 10             	mov    0x10(%ebp),%edx
f0101368:	89 54 24 04          	mov    %edx,0x4(%esp)
f010136c:	89 3c 24             	mov    %edi,(%esp)
f010136f:	e8 06 ff ff ff       	call   f010127a <tlb_invalidate>
            page_remove(pgdir, va);//删除这个映射                            
f0101374:	8b 45 10             	mov    0x10(%ebp),%eax
f0101377:	89 44 24 04          	mov    %eax,0x4(%esp)
f010137b:	89 3c 24             	mov    %edi,(%esp)
f010137e:	e8 40 ff ff ff       	call   f01012c3 <page_remove>
        }
        *entry = (page2pa(pp) | perm | PTE_P);
f0101383:	8b 45 14             	mov    0x14(%ebp),%eax
f0101386:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101389:	2b 1d 90 1e 33 f0    	sub    0xf0331e90,%ebx
f010138f:	c1 fb 03             	sar    $0x3,%ebx
f0101392:	c1 e3 0c             	shl    $0xc,%ebx
f0101395:	09 c3                	or     %eax,%ebx
f0101397:	89 1e                	mov    %ebx,(%esi)
        pgdir[PDX(va)] |= perm;                  //把va和pp的映射关系查到页目录中                       
f0101399:	8b 45 10             	mov    0x10(%ebp),%eax
f010139c:	c1 e8 16             	shr    $0x16,%eax
f010139f:	8b 55 14             	mov    0x14(%ebp),%edx
f01013a2:	09 14 87             	or     %edx,(%edi,%eax,4)
        return 0;
f01013a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013aa:	eb 05                	jmp    f01013b1 <page_insert+0x81>
        
        // cprintf("pgdir_insert\n");
        pte_t *entry = NULL;
        entry = pgdir_walk(pgdir, va, 1);    //通过pgdir_walk函数求出va对应的页表项
        if(entry == NULL) 
            return -E_NO_MEM;
f01013ac:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
            page_remove(pgdir, va);//删除这个映射                            
        }
        *entry = (page2pa(pp) | perm | PTE_P);
        pgdir[PDX(va)] |= perm;                  //把va和pp的映射关系查到页目录中                       
        return 0;
}
f01013b1:	83 c4 1c             	add    $0x1c,%esp
f01013b4:	5b                   	pop    %ebx
f01013b5:	5e                   	pop    %esi
f01013b6:	5f                   	pop    %edi
f01013b7:	5d                   	pop    %ebp
f01013b8:	c3                   	ret    

f01013b9 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013b9:	55                   	push   %ebp
f01013ba:	89 e5                	mov    %esp,%ebp
f01013bc:	53                   	push   %ebx
f01013bd:	83 ec 14             	sub    $0x14,%esp
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	//panic("mmio_map_region not implemented");
        
        size = ROUNDUP(size, PGSIZE);
f01013c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013c3:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01013c9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if(base + size > MMIOLIM)
f01013cf:	8b 15 00 93 12 f0    	mov    0xf0129300,%edx
f01013d5:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01013d8:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01013dd:	76 1c                	jbe    f01013fb <mmio_map_region+0x42>
            panic("mmin_map_region fail at size!\n");
f01013df:	c7 44 24 08 c8 74 10 	movl   $0xf01074c8,0x8(%esp)
f01013e6:	f0 
f01013e7:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f01013ee:	00 
f01013ef:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01013f6:	e8 45 ec ff ff       	call   f0100040 <_panic>
        boot_map_region(kern_pgdir, base ,size ,pa, PTE_PCD | PTE_PWT | PTE_W );
f01013fb:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101402:	00 
f0101403:	8b 45 08             	mov    0x8(%ebp),%eax
f0101406:	89 04 24             	mov    %eax,(%esp)
f0101409:	89 d9                	mov    %ebx,%ecx
f010140b:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101410:	e8 95 fd ff ff       	call   f01011aa <boot_map_region>
        base += size;
f0101415:	a1 00 93 12 f0       	mov    0xf0129300,%eax
f010141a:	01 c3                	add    %eax,%ebx
f010141c:	89 1d 00 93 12 f0    	mov    %ebx,0xf0129300
        return (void*)(base - size);
        
}
f0101422:	83 c4 14             	add    $0x14,%esp
f0101425:	5b                   	pop    %ebx
f0101426:	5d                   	pop    %ebp
f0101427:	c3                   	ret    

f0101428 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101428:	55                   	push   %ebp
f0101429:	89 e5                	mov    %esp,%ebp
f010142b:	57                   	push   %edi
f010142c:	56                   	push   %esi
f010142d:	53                   	push   %ebx
f010142e:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101431:	b8 15 00 00 00       	mov    $0x15,%eax
f0101436:	e8 1e f7 ff ff       	call   f0100b59 <nvram_read>
f010143b:	c1 e0 0a             	shl    $0xa,%eax
f010143e:	89 c2                	mov    %eax,%edx
f0101440:	85 c0                	test   %eax,%eax
f0101442:	79 06                	jns    f010144a <mem_init+0x22>
f0101444:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010144a:	c1 fa 0c             	sar    $0xc,%edx
f010144d:	89 15 38 12 33 f0    	mov    %edx,0xf0331238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101453:	b8 17 00 00 00       	mov    $0x17,%eax
f0101458:	e8 fc f6 ff ff       	call   f0100b59 <nvram_read>
f010145d:	89 c2                	mov    %eax,%edx
f010145f:	c1 e2 0a             	shl    $0xa,%edx
f0101462:	89 d0                	mov    %edx,%eax
f0101464:	85 d2                	test   %edx,%edx
f0101466:	79 06                	jns    f010146e <mem_init+0x46>
f0101468:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010146e:	c1 f8 0c             	sar    $0xc,%eax
f0101471:	74 0e                	je     f0101481 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101473:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101479:	89 15 88 1e 33 f0    	mov    %edx,0xf0331e88
f010147f:	eb 0c                	jmp    f010148d <mem_init+0x65>
	else
		npages = npages_basemem;
f0101481:	8b 15 38 12 33 f0    	mov    0xf0331238,%edx
f0101487:	89 15 88 1e 33 f0    	mov    %edx,0xf0331e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010148d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101490:	c1 e8 0a             	shr    $0xa,%eax
f0101493:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101497:	a1 38 12 33 f0       	mov    0xf0331238,%eax
f010149c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010149f:	c1 e8 0a             	shr    $0xa,%eax
f01014a2:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01014a6:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f01014ab:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ae:	c1 e8 0a             	shr    $0xa,%eax
f01014b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014b5:	c7 04 24 e8 74 10 f0 	movl   $0xf01074e8,(%esp)
f01014bc:	e8 55 2b 00 00       	call   f0104016 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014c1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014c6:	e8 dd f5 ff ff       	call   f0100aa8 <boot_alloc>
f01014cb:	a3 8c 1e 33 f0       	mov    %eax,0xf0331e8c
	memset(kern_pgdir, 0, PGSIZE);
f01014d0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014d7:	00 
f01014d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014df:	00 
f01014e0:	89 04 24             	mov    %eax,(%esp)
f01014e3:	e8 76 4c 00 00       	call   f010615e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014e8:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014f2:	77 20                	ja     f0101514 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014f8:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01014ff:	f0 
f0101500:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
f0101507:	00 
f0101508:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010150f:	e8 2c eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101514:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010151a:	83 ca 05             	or     $0x5,%edx
f010151d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
        pages = boot_alloc(npages * sizeof(struct PageInfo ));
f0101523:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f0101528:	c1 e0 03             	shl    $0x3,%eax
f010152b:	e8 78 f5 ff ff       	call   f0100aa8 <boot_alloc>
f0101530:	a3 90 1e 33 f0       	mov    %eax,0xf0331e90
        memset(pages, 0, npages * sizeof(struct PageInfo));
f0101535:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f010153b:	c1 e2 03             	shl    $0x3,%edx
f010153e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101542:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101549:	00 
f010154a:	89 04 24             	mov    %eax,(%esp)
f010154d:	e8 0c 4c 00 00       	call   f010615e <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
    
        envs = (struct Env*)boot_alloc(sizeof(struct Env)*NENV);
f0101552:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101557:	e8 4c f5 ff ff       	call   f0100aa8 <boot_alloc>
f010155c:	a3 48 12 33 f0       	mov    %eax,0xf0331248
        memset(envs, 0, sizeof(struct Env)*NENV);
f0101561:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101568:	00 
f0101569:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101570:	00 
f0101571:	89 04 24             	mov    %eax,(%esp)
f0101574:	e8 e5 4b 00 00       	call   f010615e <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101579:	e8 57 f9 ff ff       	call   f0100ed5 <page_init>

	check_page_free_list(1);
f010157e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101583:	e8 fa f5 ff ff       	call   f0100b82 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101588:	83 3d 90 1e 33 f0 00 	cmpl   $0x0,0xf0331e90
f010158f:	75 1c                	jne    f01015ad <mem_init+0x185>
		panic("'pages' is a null pointer!");
f0101591:	c7 44 24 08 e9 7d 10 	movl   $0xf0107de9,0x8(%esp)
f0101598:	f0 
f0101599:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f01015a0:	00 
f01015a1:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01015a8:	e8 93 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015ad:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f01015b2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015b7:	eb 03                	jmp    f01015bc <mem_init+0x194>
		++nfree;
f01015b9:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015ba:	8b 00                	mov    (%eax),%eax
f01015bc:	85 c0                	test   %eax,%eax
f01015be:	75 f9                	jne    f01015b9 <mem_init+0x191>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c7:	e8 f1 f9 ff ff       	call   f0100fbd <page_alloc>
f01015cc:	89 c6                	mov    %eax,%esi
f01015ce:	85 c0                	test   %eax,%eax
f01015d0:	75 24                	jne    f01015f6 <mem_init+0x1ce>
f01015d2:	c7 44 24 0c 04 7e 10 	movl   $0xf0107e04,0xc(%esp)
f01015d9:	f0 
f01015da:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01015e1:	f0 
f01015e2:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01015e9:	00 
f01015ea:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01015f1:	e8 4a ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015fd:	e8 bb f9 ff ff       	call   f0100fbd <page_alloc>
f0101602:	89 c7                	mov    %eax,%edi
f0101604:	85 c0                	test   %eax,%eax
f0101606:	75 24                	jne    f010162c <mem_init+0x204>
f0101608:	c7 44 24 0c 1a 7e 10 	movl   $0xf0107e1a,0xc(%esp)
f010160f:	f0 
f0101610:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101617:	f0 
f0101618:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f010161f:	00 
f0101620:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101627:	e8 14 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010162c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101633:	e8 85 f9 ff ff       	call   f0100fbd <page_alloc>
f0101638:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010163b:	85 c0                	test   %eax,%eax
f010163d:	75 24                	jne    f0101663 <mem_init+0x23b>
f010163f:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f0101646:	f0 
f0101647:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010164e:	f0 
f010164f:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101656:	00 
f0101657:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010165e:	e8 dd e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101663:	39 fe                	cmp    %edi,%esi
f0101665:	75 24                	jne    f010168b <mem_init+0x263>
f0101667:	c7 44 24 0c 46 7e 10 	movl   $0xf0107e46,0xc(%esp)
f010166e:	f0 
f010166f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101676:	f0 
f0101677:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010167e:	00 
f010167f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101686:	e8 b5 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010168b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010168e:	74 05                	je     f0101695 <mem_init+0x26d>
f0101690:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101693:	75 24                	jne    f01016b9 <mem_init+0x291>
f0101695:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f010169c:	f0 
f010169d:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01016a4:	f0 
f01016a5:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f01016ac:	00 
f01016ad:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01016b4:	e8 87 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016b9:	8b 15 90 1e 33 f0    	mov    0xf0331e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016bf:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f01016c4:	c1 e0 0c             	shl    $0xc,%eax
f01016c7:	89 f1                	mov    %esi,%ecx
f01016c9:	29 d1                	sub    %edx,%ecx
f01016cb:	c1 f9 03             	sar    $0x3,%ecx
f01016ce:	c1 e1 0c             	shl    $0xc,%ecx
f01016d1:	39 c1                	cmp    %eax,%ecx
f01016d3:	72 24                	jb     f01016f9 <mem_init+0x2d1>
f01016d5:	c7 44 24 0c 58 7e 10 	movl   $0xf0107e58,0xc(%esp)
f01016dc:	f0 
f01016dd:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01016e4:	f0 
f01016e5:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01016ec:	00 
f01016ed:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01016f4:	e8 47 e9 ff ff       	call   f0100040 <_panic>
f01016f9:	89 f9                	mov    %edi,%ecx
f01016fb:	29 d1                	sub    %edx,%ecx
f01016fd:	c1 f9 03             	sar    $0x3,%ecx
f0101700:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101703:	39 c8                	cmp    %ecx,%eax
f0101705:	77 24                	ja     f010172b <mem_init+0x303>
f0101707:	c7 44 24 0c 75 7e 10 	movl   $0xf0107e75,0xc(%esp)
f010170e:	f0 
f010170f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101716:	f0 
f0101717:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f010171e:	00 
f010171f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101726:	e8 15 e9 ff ff       	call   f0100040 <_panic>
f010172b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010172e:	29 d1                	sub    %edx,%ecx
f0101730:	89 ca                	mov    %ecx,%edx
f0101732:	c1 fa 03             	sar    $0x3,%edx
f0101735:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101738:	39 d0                	cmp    %edx,%eax
f010173a:	77 24                	ja     f0101760 <mem_init+0x338>
f010173c:	c7 44 24 0c 92 7e 10 	movl   $0xf0107e92,0xc(%esp)
f0101743:	f0 
f0101744:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010174b:	f0 
f010174c:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101753:	00 
f0101754:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010175b:	e8 e0 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101760:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f0101765:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101768:	c7 05 40 12 33 f0 00 	movl   $0x0,0xf0331240
f010176f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101772:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101779:	e8 3f f8 ff ff       	call   f0100fbd <page_alloc>
f010177e:	85 c0                	test   %eax,%eax
f0101780:	74 24                	je     f01017a6 <mem_init+0x37e>
f0101782:	c7 44 24 0c af 7e 10 	movl   $0xf0107eaf,0xc(%esp)
f0101789:	f0 
f010178a:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101791:	f0 
f0101792:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101799:	00 
f010179a:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01017a1:	e8 9a e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01017a6:	89 34 24             	mov    %esi,(%esp)
f01017a9:	e8 93 f8 ff ff       	call   f0101041 <page_free>
	page_free(pp1);
f01017ae:	89 3c 24             	mov    %edi,(%esp)
f01017b1:	e8 8b f8 ff ff       	call   f0101041 <page_free>
	page_free(pp2);
f01017b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017b9:	89 04 24             	mov    %eax,(%esp)
f01017bc:	e8 80 f8 ff ff       	call   f0101041 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017c8:	e8 f0 f7 ff ff       	call   f0100fbd <page_alloc>
f01017cd:	89 c6                	mov    %eax,%esi
f01017cf:	85 c0                	test   %eax,%eax
f01017d1:	75 24                	jne    f01017f7 <mem_init+0x3cf>
f01017d3:	c7 44 24 0c 04 7e 10 	movl   $0xf0107e04,0xc(%esp)
f01017da:	f0 
f01017db:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01017e2:	f0 
f01017e3:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f01017ea:	00 
f01017eb:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01017f2:	e8 49 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017fe:	e8 ba f7 ff ff       	call   f0100fbd <page_alloc>
f0101803:	89 c7                	mov    %eax,%edi
f0101805:	85 c0                	test   %eax,%eax
f0101807:	75 24                	jne    f010182d <mem_init+0x405>
f0101809:	c7 44 24 0c 1a 7e 10 	movl   $0xf0107e1a,0xc(%esp)
f0101810:	f0 
f0101811:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101818:	f0 
f0101819:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101820:	00 
f0101821:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101828:	e8 13 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010182d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101834:	e8 84 f7 ff ff       	call   f0100fbd <page_alloc>
f0101839:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010183c:	85 c0                	test   %eax,%eax
f010183e:	75 24                	jne    f0101864 <mem_init+0x43c>
f0101840:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f0101847:	f0 
f0101848:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010184f:	f0 
f0101850:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101857:	00 
f0101858:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010185f:	e8 dc e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101864:	39 fe                	cmp    %edi,%esi
f0101866:	75 24                	jne    f010188c <mem_init+0x464>
f0101868:	c7 44 24 0c 46 7e 10 	movl   $0xf0107e46,0xc(%esp)
f010186f:	f0 
f0101870:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101877:	f0 
f0101878:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f010187f:	00 
f0101880:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101887:	e8 b4 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010188c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010188f:	74 05                	je     f0101896 <mem_init+0x46e>
f0101891:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101894:	75 24                	jne    f01018ba <mem_init+0x492>
f0101896:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f010189d:	f0 
f010189e:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01018a5:	f0 
f01018a6:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f01018ad:	00 
f01018ae:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01018b5:	e8 86 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01018ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018c1:	e8 f7 f6 ff ff       	call   f0100fbd <page_alloc>
f01018c6:	85 c0                	test   %eax,%eax
f01018c8:	74 24                	je     f01018ee <mem_init+0x4c6>
f01018ca:	c7 44 24 0c af 7e 10 	movl   $0xf0107eaf,0xc(%esp)
f01018d1:	f0 
f01018d2:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01018d9:	f0 
f01018da:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f01018e1:	00 
f01018e2:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01018e9:	e8 52 e7 ff ff       	call   f0100040 <_panic>
f01018ee:	89 f0                	mov    %esi,%eax
f01018f0:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01018f6:	c1 f8 03             	sar    $0x3,%eax
f01018f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018fc:	89 c2                	mov    %eax,%edx
f01018fe:	c1 ea 0c             	shr    $0xc,%edx
f0101901:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0101907:	72 20                	jb     f0101929 <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101909:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010190d:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0101914:	f0 
f0101915:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010191c:	00 
f010191d:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0101924:	e8 17 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101929:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101930:	00 
f0101931:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101938:	00 
	return (void *)(pa + KERNBASE);
f0101939:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010193e:	89 04 24             	mov    %eax,(%esp)
f0101941:	e8 18 48 00 00       	call   f010615e <memset>
	page_free(pp0);
f0101946:	89 34 24             	mov    %esi,(%esp)
f0101949:	e8 f3 f6 ff ff       	call   f0101041 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010194e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101955:	e8 63 f6 ff ff       	call   f0100fbd <page_alloc>
f010195a:	85 c0                	test   %eax,%eax
f010195c:	75 24                	jne    f0101982 <mem_init+0x55a>
f010195e:	c7 44 24 0c be 7e 10 	movl   $0xf0107ebe,0xc(%esp)
f0101965:	f0 
f0101966:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010196d:	f0 
f010196e:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101975:	00 
f0101976:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010197d:	e8 be e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101982:	39 c6                	cmp    %eax,%esi
f0101984:	74 24                	je     f01019aa <mem_init+0x582>
f0101986:	c7 44 24 0c dc 7e 10 	movl   $0xf0107edc,0xc(%esp)
f010198d:	f0 
f010198e:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101995:	f0 
f0101996:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010199d:	00 
f010199e:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01019a5:	e8 96 e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019aa:	89 f2                	mov    %esi,%edx
f01019ac:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01019b2:	c1 fa 03             	sar    $0x3,%edx
f01019b5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019b8:	89 d0                	mov    %edx,%eax
f01019ba:	c1 e8 0c             	shr    $0xc,%eax
f01019bd:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f01019c3:	72 20                	jb     f01019e5 <mem_init+0x5bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01019c9:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01019d0:	f0 
f01019d1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019d8:	00 
f01019d9:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f01019e0:	e8 5b e6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01019e5:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01019eb:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01019f1:	80 38 00             	cmpb   $0x0,(%eax)
f01019f4:	74 24                	je     f0101a1a <mem_init+0x5f2>
f01019f6:	c7 44 24 0c ec 7e 10 	movl   $0xf0107eec,0xc(%esp)
f01019fd:	f0 
f01019fe:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101a05:	f0 
f0101a06:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101a0d:	00 
f0101a0e:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101a15:	e8 26 e6 ff ff       	call   f0100040 <_panic>
f0101a1a:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a1b:	39 d0                	cmp    %edx,%eax
f0101a1d:	75 d2                	jne    f01019f1 <mem_init+0x5c9>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a1f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a22:	89 15 40 12 33 f0    	mov    %edx,0xf0331240

	// free the pages we took
	page_free(pp0);
f0101a28:	89 34 24             	mov    %esi,(%esp)
f0101a2b:	e8 11 f6 ff ff       	call   f0101041 <page_free>
	page_free(pp1);
f0101a30:	89 3c 24             	mov    %edi,(%esp)
f0101a33:	e8 09 f6 ff ff       	call   f0101041 <page_free>
	page_free(pp2);
f0101a38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3b:	89 04 24             	mov    %eax,(%esp)
f0101a3e:	e8 fe f5 ff ff       	call   f0101041 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a43:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f0101a48:	eb 03                	jmp    f0101a4d <mem_init+0x625>
		--nfree;
f0101a4a:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a4b:	8b 00                	mov    (%eax),%eax
f0101a4d:	85 c0                	test   %eax,%eax
f0101a4f:	75 f9                	jne    f0101a4a <mem_init+0x622>
		--nfree;
	assert(nfree == 0);
f0101a51:	85 db                	test   %ebx,%ebx
f0101a53:	74 24                	je     f0101a79 <mem_init+0x651>
f0101a55:	c7 44 24 0c f6 7e 10 	movl   $0xf0107ef6,0xc(%esp)
f0101a5c:	f0 
f0101a5d:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101a64:	f0 
f0101a65:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101a6c:	00 
f0101a6d:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101a74:	e8 c7 e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a79:	c7 04 24 44 75 10 f0 	movl   $0xf0107544,(%esp)
f0101a80:	e8 91 25 00 00       	call   f0104016 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a8c:	e8 2c f5 ff ff       	call   f0100fbd <page_alloc>
f0101a91:	89 c7                	mov    %eax,%edi
f0101a93:	85 c0                	test   %eax,%eax
f0101a95:	75 24                	jne    f0101abb <mem_init+0x693>
f0101a97:	c7 44 24 0c 04 7e 10 	movl   $0xf0107e04,0xc(%esp)
f0101a9e:	f0 
f0101a9f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101aae:	00 
f0101aaf:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101ab6:	e8 85 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101abb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ac2:	e8 f6 f4 ff ff       	call   f0100fbd <page_alloc>
f0101ac7:	89 c6                	mov    %eax,%esi
f0101ac9:	85 c0                	test   %eax,%eax
f0101acb:	75 24                	jne    f0101af1 <mem_init+0x6c9>
f0101acd:	c7 44 24 0c 1a 7e 10 	movl   $0xf0107e1a,0xc(%esp)
f0101ad4:	f0 
f0101ad5:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101adc:	f0 
f0101add:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101ae4:	00 
f0101ae5:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101aec:	e8 4f e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101af1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101af8:	e8 c0 f4 ff ff       	call   f0100fbd <page_alloc>
f0101afd:	89 c3                	mov    %eax,%ebx
f0101aff:	85 c0                	test   %eax,%eax
f0101b01:	75 24                	jne    f0101b27 <mem_init+0x6ff>
f0101b03:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f0101b0a:	f0 
f0101b0b:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101b12:	f0 
f0101b13:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0101b1a:	00 
f0101b1b:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101b22:	e8 19 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b27:	39 f7                	cmp    %esi,%edi
f0101b29:	75 24                	jne    f0101b4f <mem_init+0x727>
f0101b2b:	c7 44 24 0c 46 7e 10 	movl   $0xf0107e46,0xc(%esp)
f0101b32:	f0 
f0101b33:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101b3a:	f0 
f0101b3b:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101b42:	00 
f0101b43:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101b4a:	e8 f1 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b4f:	39 c6                	cmp    %eax,%esi
f0101b51:	74 04                	je     f0101b57 <mem_init+0x72f>
f0101b53:	39 c7                	cmp    %eax,%edi
f0101b55:	75 24                	jne    f0101b7b <mem_init+0x753>
f0101b57:	c7 44 24 0c 24 75 10 	movl   $0xf0107524,0xc(%esp)
f0101b5e:	f0 
f0101b5f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101b66:	f0 
f0101b67:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0101b6e:	00 
f0101b6f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101b76:	e8 c5 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b7b:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0101b81:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101b84:	c7 05 40 12 33 f0 00 	movl   $0x0,0xf0331240
f0101b8b:	00 00 00 

        // cprintf("page_free_list:%08x\n",page_free_list);
	// should be no free memory
	assert(!page_alloc(0));
f0101b8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b95:	e8 23 f4 ff ff       	call   f0100fbd <page_alloc>
f0101b9a:	85 c0                	test   %eax,%eax
f0101b9c:	74 24                	je     f0101bc2 <mem_init+0x79a>
f0101b9e:	c7 44 24 0c af 7e 10 	movl   $0xf0107eaf,0xc(%esp)
f0101ba5:	f0 
f0101ba6:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101bad:	f0 
f0101bae:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101bb5:	00 
f0101bb6:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101bbd:	e8 7e e4 ff ff       	call   f0100040 <_panic>
        // cprintf("page_free_list:%08x\n",page_free_list);
        // cprintf("---------------\n");
	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bd0:	00 
f0101bd1:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101bd6:	89 04 24             	mov    %eax,(%esp)
f0101bd9:	e8 2f f6 ff ff       	call   f010120d <page_lookup>
f0101bde:	85 c0                	test   %eax,%eax
f0101be0:	74 24                	je     f0101c06 <mem_init+0x7de>
f0101be2:	c7 44 24 0c 64 75 10 	movl   $0xf0107564,0xc(%esp)
f0101be9:	f0 
f0101bea:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101bf1:	f0 
f0101bf2:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0101bf9:	00 
f0101bfa:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101c01:	e8 3a e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c06:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c0d:	00 
f0101c0e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c15:	00 
f0101c16:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c1a:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101c1f:	89 04 24             	mov    %eax,(%esp)
f0101c22:	e8 09 f7 ff ff       	call   f0101330 <page_insert>
f0101c27:	85 c0                	test   %eax,%eax
f0101c29:	78 24                	js     f0101c4f <mem_init+0x827>
f0101c2b:	c7 44 24 0c 9c 75 10 	movl   $0xf010759c,0xc(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101c3a:	f0 
f0101c3b:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101c42:	00 
f0101c43:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101c4a:	e8 f1 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c4f:	89 3c 24             	mov    %edi,(%esp)
f0101c52:	e8 ea f3 ff ff       	call   f0101041 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c57:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c5e:	00 
f0101c5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c66:	00 
f0101c67:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c6b:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101c70:	89 04 24             	mov    %eax,(%esp)
f0101c73:	e8 b8 f6 ff ff       	call   f0101330 <page_insert>
f0101c78:	85 c0                	test   %eax,%eax
f0101c7a:	74 24                	je     f0101ca0 <mem_init+0x878>
f0101c7c:	c7 44 24 0c cc 75 10 	movl   $0xf01075cc,0xc(%esp)
f0101c83:	f0 
f0101c84:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101c8b:	f0 
f0101c8c:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0101c93:	00 
f0101c94:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101c9b:	e8 a0 e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ca0:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0101ca6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ca9:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
f0101cae:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cb1:	8b 11                	mov    (%ecx),%edx
f0101cb3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101cb9:	89 f8                	mov    %edi,%eax
f0101cbb:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101cbe:	c1 f8 03             	sar    $0x3,%eax
f0101cc1:	c1 e0 0c             	shl    $0xc,%eax
f0101cc4:	39 c2                	cmp    %eax,%edx
f0101cc6:	74 24                	je     f0101cec <mem_init+0x8c4>
f0101cc8:	c7 44 24 0c fc 75 10 	movl   $0xf01075fc,0xc(%esp)
f0101ccf:	f0 
f0101cd0:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101cd7:	f0 
f0101cd8:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0101cdf:	00 
f0101ce0:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101ce7:	e8 54 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cec:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cf1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cf4:	e8 f3 ed ff ff       	call   f0100aec <check_va2pa>
f0101cf9:	89 f2                	mov    %esi,%edx
f0101cfb:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101cfe:	c1 fa 03             	sar    $0x3,%edx
f0101d01:	c1 e2 0c             	shl    $0xc,%edx
f0101d04:	39 d0                	cmp    %edx,%eax
f0101d06:	74 24                	je     f0101d2c <mem_init+0x904>
f0101d08:	c7 44 24 0c 24 76 10 	movl   $0xf0107624,0xc(%esp)
f0101d0f:	f0 
f0101d10:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101d17:	f0 
f0101d18:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0101d1f:	00 
f0101d20:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101d27:	e8 14 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d2c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d31:	74 24                	je     f0101d57 <mem_init+0x92f>
f0101d33:	c7 44 24 0c 01 7f 10 	movl   $0xf0107f01,0xc(%esp)
f0101d3a:	f0 
f0101d3b:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101d42:	f0 
f0101d43:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0101d4a:	00 
f0101d4b:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101d52:	e8 e9 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d57:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d5c:	74 24                	je     f0101d82 <mem_init+0x95a>
f0101d5e:	c7 44 24 0c 12 7f 10 	movl   $0xf0107f12,0xc(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0101d75:	00 
f0101d76:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101d7d:	e8 be e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d82:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d89:	00 
f0101d8a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d91:	00 
f0101d92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d96:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d99:	89 14 24             	mov    %edx,(%esp)
f0101d9c:	e8 8f f5 ff ff       	call   f0101330 <page_insert>
f0101da1:	85 c0                	test   %eax,%eax
f0101da3:	74 24                	je     f0101dc9 <mem_init+0x9a1>
f0101da5:	c7 44 24 0c 54 76 10 	movl   $0xf0107654,0xc(%esp)
f0101dac:	f0 
f0101dad:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101db4:	f0 
f0101db5:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0101dbc:	00 
f0101dbd:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101dc4:	e8 77 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dc9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dce:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101dd3:	e8 14 ed ff ff       	call   f0100aec <check_va2pa>
f0101dd8:	89 da                	mov    %ebx,%edx
f0101dda:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101de0:	c1 fa 03             	sar    $0x3,%edx
f0101de3:	c1 e2 0c             	shl    $0xc,%edx
f0101de6:	39 d0                	cmp    %edx,%eax
f0101de8:	74 24                	je     f0101e0e <mem_init+0x9e6>
f0101dea:	c7 44 24 0c 90 76 10 	movl   $0xf0107690,0xc(%esp)
f0101df1:	f0 
f0101df2:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101df9:	f0 
f0101dfa:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0101e01:	00 
f0101e02:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101e09:	e8 32 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e0e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e13:	74 24                	je     f0101e39 <mem_init+0xa11>
f0101e15:	c7 44 24 0c 23 7f 10 	movl   $0xf0107f23,0xc(%esp)
f0101e1c:	f0 
f0101e1d:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101e24:	f0 
f0101e25:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0101e2c:	00 
f0101e2d:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101e34:	e8 07 e2 ff ff       	call   f0100040 <_panic>
        // cprintf("page_free_list:%08x\n",page_free_list);
	// should be no free memory
	assert(!page_alloc(0));
f0101e39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e40:	e8 78 f1 ff ff       	call   f0100fbd <page_alloc>
f0101e45:	85 c0                	test   %eax,%eax
f0101e47:	74 24                	je     f0101e6d <mem_init+0xa45>
f0101e49:	c7 44 24 0c af 7e 10 	movl   $0xf0107eaf,0xc(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101e58:	f0 
f0101e59:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0101e60:	00 
f0101e61:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101e68:	e8 d3 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e6d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e74:	00 
f0101e75:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e7c:	00 
f0101e7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e81:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101e86:	89 04 24             	mov    %eax,(%esp)
f0101e89:	e8 a2 f4 ff ff       	call   f0101330 <page_insert>
f0101e8e:	85 c0                	test   %eax,%eax
f0101e90:	74 24                	je     f0101eb6 <mem_init+0xa8e>
f0101e92:	c7 44 24 0c 54 76 10 	movl   $0xf0107654,0xc(%esp)
f0101e99:	f0 
f0101e9a:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101ea1:	f0 
f0101ea2:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0101ea9:	00 
f0101eaa:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101eb1:	e8 8a e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eb6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ebb:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101ec0:	e8 27 ec ff ff       	call   f0100aec <check_va2pa>
f0101ec5:	89 da                	mov    %ebx,%edx
f0101ec7:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101ecd:	c1 fa 03             	sar    $0x3,%edx
f0101ed0:	c1 e2 0c             	shl    $0xc,%edx
f0101ed3:	39 d0                	cmp    %edx,%eax
f0101ed5:	74 24                	je     f0101efb <mem_init+0xad3>
f0101ed7:	c7 44 24 0c 90 76 10 	movl   $0xf0107690,0xc(%esp)
f0101ede:	f0 
f0101edf:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101ee6:	f0 
f0101ee7:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0101eee:	00 
f0101eef:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101ef6:	e8 45 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101efb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f00:	74 24                	je     f0101f26 <mem_init+0xafe>
f0101f02:	c7 44 24 0c 23 7f 10 	movl   $0xf0107f23,0xc(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101f11:	f0 
f0101f12:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0101f19:	00 
f0101f1a:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101f21:	e8 1a e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2d:	e8 8b f0 ff ff       	call   f0100fbd <page_alloc>
f0101f32:	85 c0                	test   %eax,%eax
f0101f34:	74 24                	je     f0101f5a <mem_init+0xb32>
f0101f36:	c7 44 24 0c af 7e 10 	movl   $0xf0107eaf,0xc(%esp)
f0101f3d:	f0 
f0101f3e:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101f45:	f0 
f0101f46:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0101f4d:	00 
f0101f4e:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101f55:	e8 e6 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f5a:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f0101f60:	8b 02                	mov    (%edx),%eax
f0101f62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f67:	89 c1                	mov    %eax,%ecx
f0101f69:	c1 e9 0c             	shr    $0xc,%ecx
f0101f6c:	3b 0d 88 1e 33 f0    	cmp    0xf0331e88,%ecx
f0101f72:	72 20                	jb     f0101f94 <mem_init+0xb6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f74:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f78:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0101f87:	00 
f0101f88:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101f8f:	e8 ac e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f94:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fa3:	00 
f0101fa4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fab:	00 
f0101fac:	89 14 24             	mov    %edx,(%esp)
f0101faf:	e8 ed f0 ff ff       	call   f01010a1 <pgdir_walk>
f0101fb4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101fb7:	83 c2 04             	add    $0x4,%edx
f0101fba:	39 d0                	cmp    %edx,%eax
f0101fbc:	74 24                	je     f0101fe2 <mem_init+0xbba>
f0101fbe:	c7 44 24 0c c0 76 10 	movl   $0xf01076c0,0xc(%esp)
f0101fc5:	f0 
f0101fc6:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0101fcd:	f0 
f0101fce:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0101fd5:	00 
f0101fd6:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0101fdd:	e8 5e e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fe2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101fe9:	00 
f0101fea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ff1:	00 
f0101ff2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ff6:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101ffb:	89 04 24             	mov    %eax,(%esp)
f0101ffe:	e8 2d f3 ff ff       	call   f0101330 <page_insert>
f0102003:	85 c0                	test   %eax,%eax
f0102005:	74 24                	je     f010202b <mem_init+0xc03>
f0102007:	c7 44 24 0c 00 77 10 	movl   $0xf0107700,0xc(%esp)
f010200e:	f0 
f010200f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102016:	f0 
f0102017:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f010201e:	00 
f010201f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010202b:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0102031:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102034:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102039:	89 c8                	mov    %ecx,%eax
f010203b:	e8 ac ea ff ff       	call   f0100aec <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102040:	89 da                	mov    %ebx,%edx
f0102042:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102048:	c1 fa 03             	sar    $0x3,%edx
f010204b:	c1 e2 0c             	shl    $0xc,%edx
f010204e:	39 d0                	cmp    %edx,%eax
f0102050:	74 24                	je     f0102076 <mem_init+0xc4e>
f0102052:	c7 44 24 0c 90 76 10 	movl   $0xf0107690,0xc(%esp)
f0102059:	f0 
f010205a:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102061:	f0 
f0102062:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102069:	00 
f010206a:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102071:	e8 ca df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102076:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010207b:	74 24                	je     f01020a1 <mem_init+0xc79>
f010207d:	c7 44 24 0c 23 7f 10 	movl   $0xf0107f23,0xc(%esp)
f0102084:	f0 
f0102085:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010208c:	f0 
f010208d:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0102094:	00 
f0102095:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010209c:	e8 9f df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020a8:	00 
f01020a9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020b0:	00 
f01020b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b4:	89 04 24             	mov    %eax,(%esp)
f01020b7:	e8 e5 ef ff ff       	call   f01010a1 <pgdir_walk>
f01020bc:	f6 00 04             	testb  $0x4,(%eax)
f01020bf:	75 24                	jne    f01020e5 <mem_init+0xcbd>
f01020c1:	c7 44 24 0c 40 77 10 	movl   $0xf0107740,0xc(%esp)
f01020c8:	f0 
f01020c9:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01020d0:	f0 
f01020d1:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01020d8:	00 
f01020d9:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01020e0:	e8 5b df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020e5:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01020ea:	f6 00 04             	testb  $0x4,(%eax)
f01020ed:	75 24                	jne    f0102113 <mem_init+0xceb>
f01020ef:	c7 44 24 0c 34 7f 10 	movl   $0xf0107f34,0xc(%esp)
f01020f6:	f0 
f01020f7:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01020fe:	f0 
f01020ff:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102106:	00 
f0102107:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010210e:	e8 2d df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102113:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010211a:	00 
f010211b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102122:	00 
f0102123:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102127:	89 04 24             	mov    %eax,(%esp)
f010212a:	e8 01 f2 ff ff       	call   f0101330 <page_insert>
f010212f:	85 c0                	test   %eax,%eax
f0102131:	74 24                	je     f0102157 <mem_init+0xd2f>
f0102133:	c7 44 24 0c 54 76 10 	movl   $0xf0107654,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102152:	e8 e9 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102157:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010215e:	00 
f010215f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102166:	00 
f0102167:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010216c:	89 04 24             	mov    %eax,(%esp)
f010216f:	e8 2d ef ff ff       	call   f01010a1 <pgdir_walk>
f0102174:	f6 00 02             	testb  $0x2,(%eax)
f0102177:	75 24                	jne    f010219d <mem_init+0xd75>
f0102179:	c7 44 24 0c 74 77 10 	movl   $0xf0107774,0xc(%esp)
f0102180:	f0 
f0102181:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102188:	f0 
f0102189:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0102190:	00 
f0102191:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102198:	e8 a3 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010219d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021a4:	00 
f01021a5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021ac:	00 
f01021ad:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01021b2:	89 04 24             	mov    %eax,(%esp)
f01021b5:	e8 e7 ee ff ff       	call   f01010a1 <pgdir_walk>
f01021ba:	f6 00 04             	testb  $0x4,(%eax)
f01021bd:	74 24                	je     f01021e3 <mem_init+0xdbb>
f01021bf:	c7 44 24 0c a8 77 10 	movl   $0xf01077a8,0xc(%esp)
f01021c6:	f0 
f01021c7:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01021ce:	f0 
f01021cf:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01021d6:	00 
f01021d7:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01021de:	e8 5d de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021e3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021ea:	00 
f01021eb:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01021f2:	00 
f01021f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01021f7:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01021fc:	89 04 24             	mov    %eax,(%esp)
f01021ff:	e8 2c f1 ff ff       	call   f0101330 <page_insert>
f0102204:	85 c0                	test   %eax,%eax
f0102206:	78 24                	js     f010222c <mem_init+0xe04>
f0102208:	c7 44 24 0c e0 77 10 	movl   $0xf01077e0,0xc(%esp)
f010220f:	f0 
f0102210:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102217:	f0 
f0102218:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f010221f:	00 
f0102220:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102227:	e8 14 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010222c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102233:	00 
f0102234:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010223b:	00 
f010223c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102240:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102245:	89 04 24             	mov    %eax,(%esp)
f0102248:	e8 e3 f0 ff ff       	call   f0101330 <page_insert>
f010224d:	85 c0                	test   %eax,%eax
f010224f:	74 24                	je     f0102275 <mem_init+0xe4d>
f0102251:	c7 44 24 0c 18 78 10 	movl   $0xf0107818,0xc(%esp)
f0102258:	f0 
f0102259:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102260:	f0 
f0102261:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102268:	00 
f0102269:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102270:	e8 cb dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102275:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010227c:	00 
f010227d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102284:	00 
f0102285:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010228a:	89 04 24             	mov    %eax,(%esp)
f010228d:	e8 0f ee ff ff       	call   f01010a1 <pgdir_walk>
f0102292:	f6 00 04             	testb  $0x4,(%eax)
f0102295:	74 24                	je     f01022bb <mem_init+0xe93>
f0102297:	c7 44 24 0c a8 77 10 	movl   $0xf01077a8,0xc(%esp)
f010229e:	f0 
f010229f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01022a6:	f0 
f01022a7:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01022ae:	00 
f01022af:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01022b6:	e8 85 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022bb:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01022c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022c3:	ba 00 00 00 00       	mov    $0x0,%edx
f01022c8:	e8 1f e8 ff ff       	call   f0100aec <check_va2pa>
f01022cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022d0:	89 f0                	mov    %esi,%eax
f01022d2:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01022d8:	c1 f8 03             	sar    $0x3,%eax
f01022db:	c1 e0 0c             	shl    $0xc,%eax
f01022de:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01022e1:	74 24                	je     f0102307 <mem_init+0xedf>
f01022e3:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01022fa:	00 
f01022fb:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102302:	e8 39 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102307:	ba 00 10 00 00       	mov    $0x1000,%edx
f010230c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010230f:	e8 d8 e7 ff ff       	call   f0100aec <check_va2pa>
f0102314:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102317:	74 24                	je     f010233d <mem_init+0xf15>
f0102319:	c7 44 24 0c 80 78 10 	movl   $0xf0107880,0xc(%esp)
f0102320:	f0 
f0102321:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102328:	f0 
f0102329:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102330:	00 
f0102331:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102338:	e8 03 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010233d:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102342:	74 24                	je     f0102368 <mem_init+0xf40>
f0102344:	c7 44 24 0c 4a 7f 10 	movl   $0xf0107f4a,0xc(%esp)
f010234b:	f0 
f010234c:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102353:	f0 
f0102354:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010235b:	00 
f010235c:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102363:	e8 d8 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102368:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010236d:	74 24                	je     f0102393 <mem_init+0xf6b>
f010236f:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f0102376:	f0 
f0102377:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010237e:	f0 
f010237f:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102386:	00 
f0102387:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010238e:	e8 ad dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102393:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010239a:	e8 1e ec ff ff       	call   f0100fbd <page_alloc>
f010239f:	85 c0                	test   %eax,%eax
f01023a1:	74 04                	je     f01023a7 <mem_init+0xf7f>
f01023a3:	39 c3                	cmp    %eax,%ebx
f01023a5:	74 24                	je     f01023cb <mem_init+0xfa3>
f01023a7:	c7 44 24 0c b0 78 10 	movl   $0xf01078b0,0xc(%esp)
f01023ae:	f0 
f01023af:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01023b6:	f0 
f01023b7:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f01023be:	00 
f01023bf:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01023d2:	00 
f01023d3:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01023d8:	89 04 24             	mov    %eax,(%esp)
f01023db:	e8 e3 ee ff ff       	call   f01012c3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023e0:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f01023e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01023e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01023ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023f1:	e8 f6 e6 ff ff       	call   f0100aec <check_va2pa>
f01023f6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023f9:	74 24                	je     f010241f <mem_init+0xff7>
f01023fb:	c7 44 24 0c d4 78 10 	movl   $0xf01078d4,0xc(%esp)
f0102402:	f0 
f0102403:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010240a:	f0 
f010240b:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0102412:	00 
f0102413:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010241a:	e8 21 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010241f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102424:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102427:	e8 c0 e6 ff ff       	call   f0100aec <check_va2pa>
f010242c:	89 f2                	mov    %esi,%edx
f010242e:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102434:	c1 fa 03             	sar    $0x3,%edx
f0102437:	c1 e2 0c             	shl    $0xc,%edx
f010243a:	39 d0                	cmp    %edx,%eax
f010243c:	74 24                	je     f0102462 <mem_init+0x103a>
f010243e:	c7 44 24 0c 80 78 10 	movl   $0xf0107880,0xc(%esp)
f0102445:	f0 
f0102446:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010244d:	f0 
f010244e:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102455:	00 
f0102456:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010245d:	e8 de db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102462:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102467:	74 24                	je     f010248d <mem_init+0x1065>
f0102469:	c7 44 24 0c 01 7f 10 	movl   $0xf0107f01,0xc(%esp)
f0102470:	f0 
f0102471:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102478:	f0 
f0102479:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102480:	00 
f0102481:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102488:	e8 b3 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010248d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102492:	74 24                	je     f01024b8 <mem_init+0x1090>
f0102494:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f010249b:	f0 
f010249c:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01024a3:	f0 
f01024a4:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01024ab:	00 
f01024ac:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01024b3:	e8 88 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01024b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01024bf:	00 
f01024c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024c7:	00 
f01024c8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024cc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024cf:	89 0c 24             	mov    %ecx,(%esp)
f01024d2:	e8 59 ee ff ff       	call   f0101330 <page_insert>
f01024d7:	85 c0                	test   %eax,%eax
f01024d9:	74 24                	je     f01024ff <mem_init+0x10d7>
f01024db:	c7 44 24 0c f8 78 10 	movl   $0xf01078f8,0xc(%esp)
f01024e2:	f0 
f01024e3:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01024ea:	f0 
f01024eb:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f01024f2:	00 
f01024f3:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01024fa:	e8 41 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01024ff:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102504:	75 24                	jne    f010252a <mem_init+0x1102>
f0102506:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f010250d:	f0 
f010250e:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102515:	f0 
f0102516:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f010251d:	00 
f010251e:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102525:	e8 16 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010252a:	83 3e 00             	cmpl   $0x0,(%esi)
f010252d:	74 24                	je     f0102553 <mem_init+0x112b>
f010252f:	c7 44 24 0c 78 7f 10 	movl   $0xf0107f78,0xc(%esp)
f0102536:	f0 
f0102537:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010253e:	f0 
f010253f:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102546:	00 
f0102547:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010254e:	e8 ed da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102553:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010255a:	00 
f010255b:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102560:	89 04 24             	mov    %eax,(%esp)
f0102563:	e8 5b ed ff ff       	call   f01012c3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102568:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010256d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102570:	ba 00 00 00 00       	mov    $0x0,%edx
f0102575:	e8 72 e5 ff ff       	call   f0100aec <check_va2pa>
f010257a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010257d:	74 24                	je     f01025a3 <mem_init+0x117b>
f010257f:	c7 44 24 0c d4 78 10 	movl   $0xf01078d4,0xc(%esp)
f0102586:	f0 
f0102587:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010258e:	f0 
f010258f:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102596:	00 
f0102597:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010259e:	e8 9d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01025a3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025ab:	e8 3c e5 ff ff       	call   f0100aec <check_va2pa>
f01025b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025b3:	74 24                	je     f01025d9 <mem_init+0x11b1>
f01025b5:	c7 44 24 0c 30 79 10 	movl   $0xf0107930,0xc(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01025c4:	f0 
f01025c5:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f01025cc:	00 
f01025cd:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01025d9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025de:	74 24                	je     f0102604 <mem_init+0x11dc>
f01025e0:	c7 44 24 0c 8d 7f 10 	movl   $0xf0107f8d,0xc(%esp)
f01025e7:	f0 
f01025e8:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01025ef:	f0 
f01025f0:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f01025f7:	00 
f01025f8:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01025ff:	e8 3c da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102604:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102609:	74 24                	je     f010262f <mem_init+0x1207>
f010260b:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f0102612:	f0 
f0102613:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010261a:	f0 
f010261b:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102622:	00 
f0102623:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010262a:	e8 11 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010262f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102636:	e8 82 e9 ff ff       	call   f0100fbd <page_alloc>
f010263b:	85 c0                	test   %eax,%eax
f010263d:	74 04                	je     f0102643 <mem_init+0x121b>
f010263f:	39 c6                	cmp    %eax,%esi
f0102641:	74 24                	je     f0102667 <mem_init+0x123f>
f0102643:	c7 44 24 0c 58 79 10 	movl   $0xf0107958,0xc(%esp)
f010264a:	f0 
f010264b:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102652:	f0 
f0102653:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f010265a:	00 
f010265b:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102662:	e8 d9 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102667:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010266e:	e8 4a e9 ff ff       	call   f0100fbd <page_alloc>
f0102673:	85 c0                	test   %eax,%eax
f0102675:	74 24                	je     f010269b <mem_init+0x1273>
f0102677:	c7 44 24 0c af 7e 10 	movl   $0xf0107eaf,0xc(%esp)
f010267e:	f0 
f010267f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102686:	f0 
f0102687:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f010268e:	00 
f010268f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102696:	e8 a5 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010269b:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01026a0:	8b 08                	mov    (%eax),%ecx
f01026a2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026a8:	89 fa                	mov    %edi,%edx
f01026aa:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01026b0:	c1 fa 03             	sar    $0x3,%edx
f01026b3:	c1 e2 0c             	shl    $0xc,%edx
f01026b6:	39 d1                	cmp    %edx,%ecx
f01026b8:	74 24                	je     f01026de <mem_init+0x12b6>
f01026ba:	c7 44 24 0c fc 75 10 	movl   $0xf01075fc,0xc(%esp)
f01026c1:	f0 
f01026c2:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01026c9:	f0 
f01026ca:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f01026d1:	00 
f01026d2:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01026d9:	e8 62 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01026de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01026e4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01026e9:	74 24                	je     f010270f <mem_init+0x12e7>
f01026eb:	c7 44 24 0c 12 7f 10 	movl   $0xf0107f12,0xc(%esp)
f01026f2:	f0 
f01026f3:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01026fa:	f0 
f01026fb:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f0102702:	00 
f0102703:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010270a:	e8 31 d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010270f:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102715:	89 3c 24             	mov    %edi,(%esp)
f0102718:	e8 24 e9 ff ff       	call   f0101041 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010271d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102724:	00 
f0102725:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010272c:	00 
f010272d:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102732:	89 04 24             	mov    %eax,(%esp)
f0102735:	e8 67 e9 ff ff       	call   f01010a1 <pgdir_walk>
f010273a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010273d:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0102743:	8b 51 04             	mov    0x4(%ecx),%edx
f0102746:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010274c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010274f:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f0102755:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102758:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010275b:	c1 ea 0c             	shr    $0xc,%edx
f010275e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102761:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102764:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102767:	72 23                	jb     f010278c <mem_init+0x1364>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102769:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010276c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102770:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0102777:	f0 
f0102778:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f010277f:	00 
f0102780:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102787:	e8 b4 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010278c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010278f:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102795:	39 d0                	cmp    %edx,%eax
f0102797:	74 24                	je     f01027bd <mem_init+0x1395>
f0102799:	c7 44 24 0c 9e 7f 10 	movl   $0xf0107f9e,0xc(%esp)
f01027a0:	f0 
f01027a1:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01027a8:	f0 
f01027a9:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01027b0:	00 
f01027b1:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01027b8:	e8 83 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027bd:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01027c4:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027ca:	89 f8                	mov    %edi,%eax
f01027cc:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01027d2:	c1 f8 03             	sar    $0x3,%eax
f01027d5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027d8:	89 c1                	mov    %eax,%ecx
f01027da:	c1 e9 0c             	shr    $0xc,%ecx
f01027dd:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01027e0:	77 20                	ja     f0102802 <mem_init+0x13da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027e6:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01027ed:	f0 
f01027ee:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027f5:	00 
f01027f6:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f01027fd:	e8 3e d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102802:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102809:	00 
f010280a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102811:	00 
	return (void *)(pa + KERNBASE);
f0102812:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102817:	89 04 24             	mov    %eax,(%esp)
f010281a:	e8 3f 39 00 00       	call   f010615e <memset>
	page_free(pp0);
f010281f:	89 3c 24             	mov    %edi,(%esp)
f0102822:	e8 1a e8 ff ff       	call   f0101041 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102827:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010282e:	00 
f010282f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102836:	00 
f0102837:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010283c:	89 04 24             	mov    %eax,(%esp)
f010283f:	e8 5d e8 ff ff       	call   f01010a1 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102844:	89 fa                	mov    %edi,%edx
f0102846:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f010284c:	c1 fa 03             	sar    $0x3,%edx
f010284f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102852:	89 d0                	mov    %edx,%eax
f0102854:	c1 e8 0c             	shr    $0xc,%eax
f0102857:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f010285d:	72 20                	jb     f010287f <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010285f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102863:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f010286a:	f0 
f010286b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102872:	00 
f0102873:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f010287a:	e8 c1 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010287f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102885:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102888:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010288e:	f6 00 01             	testb  $0x1,(%eax)
f0102891:	74 24                	je     f01028b7 <mem_init+0x148f>
f0102893:	c7 44 24 0c b6 7f 10 	movl   $0xf0107fb6,0xc(%esp)
f010289a:	f0 
f010289b:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01028a2:	f0 
f01028a3:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f01028aa:	00 
f01028ab:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01028b2:	e8 89 d7 ff ff       	call   f0100040 <_panic>
f01028b7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028ba:	39 d0                	cmp    %edx,%eax
f01028bc:	75 d0                	jne    f010288e <mem_init+0x1466>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028be:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01028c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028c9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01028cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01028d2:	89 0d 40 12 33 f0    	mov    %ecx,0xf0331240

	// free the pages we took
	page_free(pp0);
f01028d8:	89 3c 24             	mov    %edi,(%esp)
f01028db:	e8 61 e7 ff ff       	call   f0101041 <page_free>
	page_free(pp1);
f01028e0:	89 34 24             	mov    %esi,(%esp)
f01028e3:	e8 59 e7 ff ff       	call   f0101041 <page_free>
	page_free(pp2);
f01028e8:	89 1c 24             	mov    %ebx,(%esp)
f01028eb:	e8 51 e7 ff ff       	call   f0101041 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028f0:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01028f7:	00 
f01028f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028ff:	e8 b5 ea ff ff       	call   f01013b9 <mmio_map_region>
f0102904:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102906:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010290d:	00 
f010290e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102915:	e8 9f ea ff ff       	call   f01013b9 <mmio_map_region>
f010291a:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010291c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102922:	76 0d                	jbe    f0102931 <mem_init+0x1509>
f0102924:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010292a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010292f:	76 24                	jbe    f0102955 <mem_init+0x152d>
f0102931:	c7 44 24 0c 7c 79 10 	movl   $0xf010797c,0xc(%esp)
f0102938:	f0 
f0102939:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102940:	f0 
f0102941:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0102948:	00 
f0102949:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102950:	e8 eb d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102955:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010295b:	76 0e                	jbe    f010296b <mem_init+0x1543>
f010295d:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102963:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102969:	76 24                	jbe    f010298f <mem_init+0x1567>
f010296b:	c7 44 24 0c a4 79 10 	movl   $0xf01079a4,0xc(%esp)
f0102972:	f0 
f0102973:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010297a:	f0 
f010297b:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102982:	00 
f0102983:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010298a:	e8 b1 d6 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010298f:	89 da                	mov    %ebx,%edx
f0102991:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102993:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102999:	74 24                	je     f01029bf <mem_init+0x1597>
f010299b:	c7 44 24 0c cc 79 10 	movl   $0xf01079cc,0xc(%esp)
f01029a2:	f0 
f01029a3:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01029aa:	f0 
f01029ab:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f01029b2:	00 
f01029b3:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01029ba:	e8 81 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01029bf:	39 c6                	cmp    %eax,%esi
f01029c1:	73 24                	jae    f01029e7 <mem_init+0x15bf>
f01029c3:	c7 44 24 0c cd 7f 10 	movl   $0xf0107fcd,0xc(%esp)
f01029ca:	f0 
f01029cb:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01029d2:	f0 
f01029d3:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f01029da:	00 
f01029db:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01029e2:	e8 59 d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029e7:	8b 3d 8c 1e 33 f0    	mov    0xf0331e8c,%edi
f01029ed:	89 da                	mov    %ebx,%edx
f01029ef:	89 f8                	mov    %edi,%eax
f01029f1:	e8 f6 e0 ff ff       	call   f0100aec <check_va2pa>
f01029f6:	85 c0                	test   %eax,%eax
f01029f8:	74 24                	je     f0102a1e <mem_init+0x15f6>
f01029fa:	c7 44 24 0c f4 79 10 	movl   $0xf01079f4,0xc(%esp)
f0102a01:	f0 
f0102a02:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102a09:	f0 
f0102a0a:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102a11:	00 
f0102a12:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102a19:	e8 22 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a1e:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a24:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a27:	89 c2                	mov    %eax,%edx
f0102a29:	89 f8                	mov    %edi,%eax
f0102a2b:	e8 bc e0 ff ff       	call   f0100aec <check_va2pa>
f0102a30:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a35:	74 24                	je     f0102a5b <mem_init+0x1633>
f0102a37:	c7 44 24 0c 18 7a 10 	movl   $0xf0107a18,0xc(%esp)
f0102a3e:	f0 
f0102a3f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102a46:	f0 
f0102a47:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0102a4e:	00 
f0102a4f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102a56:	e8 e5 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a5b:	89 f2                	mov    %esi,%edx
f0102a5d:	89 f8                	mov    %edi,%eax
f0102a5f:	e8 88 e0 ff ff       	call   f0100aec <check_va2pa>
f0102a64:	85 c0                	test   %eax,%eax
f0102a66:	74 24                	je     f0102a8c <mem_init+0x1664>
f0102a68:	c7 44 24 0c 48 7a 10 	movl   $0xf0107a48,0xc(%esp)
f0102a6f:	f0 
f0102a70:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102a77:	f0 
f0102a78:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0102a7f:	00 
f0102a80:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102a87:	e8 b4 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a8c:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a92:	89 f8                	mov    %edi,%eax
f0102a94:	e8 53 e0 ff ff       	call   f0100aec <check_va2pa>
f0102a99:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a9c:	74 24                	je     f0102ac2 <mem_init+0x169a>
f0102a9e:	c7 44 24 0c 6c 7a 10 	movl   $0xf0107a6c,0xc(%esp)
f0102aa5:	f0 
f0102aa6:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102aad:	f0 
f0102aae:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102ab5:	00 
f0102ab6:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102abd:	e8 7e d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102ac2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ac9:	00 
f0102aca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ace:	89 3c 24             	mov    %edi,(%esp)
f0102ad1:	e8 cb e5 ff ff       	call   f01010a1 <pgdir_walk>
f0102ad6:	f6 00 1a             	testb  $0x1a,(%eax)
f0102ad9:	75 24                	jne    f0102aff <mem_init+0x16d7>
f0102adb:	c7 44 24 0c 98 7a 10 	movl   $0xf0107a98,0xc(%esp)
f0102ae2:	f0 
f0102ae3:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102aea:	f0 
f0102aeb:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0102af2:	00 
f0102af3:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102afa:	e8 41 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102aff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b06:	00 
f0102b07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b0b:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b10:	89 04 24             	mov    %eax,(%esp)
f0102b13:	e8 89 e5 ff ff       	call   f01010a1 <pgdir_walk>
f0102b18:	f6 00 04             	testb  $0x4,(%eax)
f0102b1b:	74 24                	je     f0102b41 <mem_init+0x1719>
f0102b1d:	c7 44 24 0c dc 7a 10 	movl   $0xf0107adc,0xc(%esp)
f0102b24:	f0 
f0102b25:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102b2c:	f0 
f0102b2d:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102b34:	00 
f0102b35:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102b3c:	e8 ff d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b41:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b48:	00 
f0102b49:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b4d:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b52:	89 04 24             	mov    %eax,(%esp)
f0102b55:	e8 47 e5 ff ff       	call   f01010a1 <pgdir_walk>
f0102b5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102b60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b67:	00 
f0102b68:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b6b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102b6f:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b74:	89 04 24             	mov    %eax,(%esp)
f0102b77:	e8 25 e5 ff ff       	call   f01010a1 <pgdir_walk>
f0102b7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b89:	00 
f0102b8a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b8e:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b93:	89 04 24             	mov    %eax,(%esp)
f0102b96:	e8 06 e5 ff ff       	call   f01010a1 <pgdir_walk>
f0102b9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102ba1:	c7 04 24 df 7f 10 f0 	movl   $0xf0107fdf,(%esp)
f0102ba8:	e8 69 14 00 00       	call   f0104016 <cprintf>
	// LAB 3: Your code here.

	//////////////////////////////////////////////////////////////////////
//======= 这里好像注释的位置混乱了，产生原因不明，但不影响理解与完成
        
        boot_map_region(kern_pgdir, 
f0102bad:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bb2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bb7:	77 20                	ja     f0102bd9 <mem_init+0x17b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bbd:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102bc4:	f0 
f0102bc5:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0102bcc:	00 
f0102bcd:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102bd4:	e8 67 d4 ff ff       	call   f0100040 <_panic>
                        UPAGES, 
                        ROUNDUP((npages * (sizeof(struct PageInfo))), PGSIZE),
f0102bd9:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f0102bdf:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102be6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	// LAB 3: Your code here.

	//////////////////////////////////////////////////////////////////////
//======= 这里好像注释的位置混乱了，产生原因不明，但不影响理解与完成
        
        boot_map_region(kern_pgdir, 
f0102bec:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102bf3:	00 
	return (physaddr_t)kva - KERNBASE;
f0102bf4:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bf9:	89 04 24             	mov    %eax,(%esp)
f0102bfc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c01:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102c06:	e8 9f e5 ff ff       	call   f01011aa <boot_map_region>
                        UPAGES, 
                        ROUNDUP((npages * (sizeof(struct PageInfo))), PGSIZE),
                        PADDR(pages),
                        (PTE_U | PTE_P));

        boot_map_region(kern_pgdir,
f0102c0b:	a1 48 12 33 f0       	mov    0xf0331248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c10:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c15:	77 20                	ja     f0102c37 <mem_init+0x180f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c17:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c1b:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102c22:	f0 
f0102c23:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f0102c2a:	00 
f0102c2b:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102c32:	e8 09 d4 ff ff       	call   f0100040 <_panic>
                        UENVS,
                        ROUNDUP((npages * (sizeof(struct PageInfo))), PGSIZE),
f0102c37:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f0102c3d:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102c44:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
                        UPAGES, 
                        ROUNDUP((npages * (sizeof(struct PageInfo))), PGSIZE),
                        PADDR(pages),
                        (PTE_U | PTE_P));

        boot_map_region(kern_pgdir,
f0102c4a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c51:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c52:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c57:	89 04 24             	mov    %eax,(%esp)
f0102c5a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c5f:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102c64:	e8 41 e5 ff ff       	call   f01011aa <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c69:	b8 00 f0 11 f0       	mov    $0xf011f000,%eax
f0102c6e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c73:	77 20                	ja     f0102c95 <mem_init+0x186d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c79:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102c80:	f0 
f0102c81:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
f0102c88:	00 
f0102c89:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102c90:	e8 ab d3 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

        boot_map_region(kern_pgdir,
f0102c95:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c9c:	00 
f0102c9d:	c7 04 24 00 f0 11 00 	movl   $0x11f000,(%esp)
f0102ca4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102ca9:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102cae:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102cb3:	e8 f2 e4 ff ff       	call   f01011aa <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
        
        boot_map_region(kern_pgdir,
f0102cb8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102cbf:	00 
f0102cc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cc7:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102ccc:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102cd1:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102cd6:	e8 cf e4 ff ff       	call   f01011aa <boot_map_region>
f0102cdb:	c7 45 cc 00 30 33 f0 	movl   $0xf0333000,-0x34(%ebp)
f0102ce2:	bb 00 30 33 f0       	mov    $0xf0333000,%ebx
f0102ce7:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cec:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102cf2:	77 20                	ja     f0102d14 <mem_init+0x18ec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cf8:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102cff:	f0 
f0102d00:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f0102d07:	00 
f0102d08:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102d0f:	e8 2c d3 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
        uint32_t i;
        uintptr_t kstacktop_i;
        for(i=0;i < NCPU ;i++){
            kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
            boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W);
f0102d14:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d1b:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d1c:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
        uint32_t i;
        uintptr_t kstacktop_i;
        for(i=0;i < NCPU ;i++){
            kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
            boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W);
f0102d22:	89 04 24             	mov    %eax,(%esp)
f0102d25:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d2a:	89 f2                	mov    %esi,%edx
f0102d2c:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102d31:	e8 74 e4 ff ff       	call   f01011aa <boot_map_region>
f0102d36:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d3c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
        uint32_t i;
        uintptr_t kstacktop_i;
        for(i=0;i < NCPU ;i++){
f0102d42:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d48:	75 a2                	jne    f0102cec <mem_init+0x18c4>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d4a:	8b 1d 8c 1e 33 f0    	mov    0xf0331e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d50:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f0102d56:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d59:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d60:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d66:	be 00 00 00 00       	mov    $0x0,%esi
f0102d6b:	eb 70                	jmp    f0102ddd <mem_init+0x19b5>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d6d:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d73:	89 d8                	mov    %ebx,%eax
f0102d75:	e8 72 dd ff ff       	call   f0100aec <check_va2pa>
f0102d7a:	8b 15 90 1e 33 f0    	mov    0xf0331e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d80:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d86:	77 20                	ja     f0102da8 <mem_init+0x1980>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d88:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d8c:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102d93:	f0 
f0102d94:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0102d9b:	00 
f0102d9c:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102da3:	e8 98 d2 ff ff       	call   f0100040 <_panic>
f0102da8:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102daf:	39 d0                	cmp    %edx,%eax
f0102db1:	74 24                	je     f0102dd7 <mem_init+0x19af>
f0102db3:	c7 44 24 0c 10 7b 10 	movl   $0xf0107b10,0xc(%esp)
f0102dba:	f0 
f0102dbb:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102dc2:	f0 
f0102dc3:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0102dca:	00 
f0102dcb:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102dd2:	e8 69 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102dd7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ddd:	39 f7                	cmp    %esi,%edi
f0102ddf:	77 8c                	ja     f0102d6d <mem_init+0x1945>
f0102de1:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102de6:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102dec:	89 d8                	mov    %ebx,%eax
f0102dee:	e8 f9 dc ff ff       	call   f0100aec <check_va2pa>
f0102df3:	8b 15 48 12 33 f0    	mov    0xf0331248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102df9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102dff:	77 20                	ja     f0102e21 <mem_init+0x19f9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e01:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e05:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102e0c:	f0 
f0102e0d:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102e14:	00 
f0102e15:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102e1c:	e8 1f d2 ff ff       	call   f0100040 <_panic>
f0102e21:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102e28:	39 d0                	cmp    %edx,%eax
f0102e2a:	74 24                	je     f0102e50 <mem_init+0x1a28>
f0102e2c:	c7 44 24 0c 44 7b 10 	movl   $0xf0107b44,0xc(%esp)
f0102e33:	f0 
f0102e34:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102e3b:	f0 
f0102e3c:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102e43:	00 
f0102e44:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102e4b:	e8 f0 d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e50:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e56:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102e5c:	75 88                	jne    f0102de6 <mem_init+0x19be>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e5e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e61:	c1 e7 0c             	shl    $0xc,%edi
f0102e64:	be 00 00 00 00       	mov    $0x0,%esi
f0102e69:	eb 3b                	jmp    f0102ea6 <mem_init+0x1a7e>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e6b:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e71:	89 d8                	mov    %ebx,%eax
f0102e73:	e8 74 dc ff ff       	call   f0100aec <check_va2pa>
f0102e78:	39 c6                	cmp    %eax,%esi
f0102e7a:	74 24                	je     f0102ea0 <mem_init+0x1a78>
f0102e7c:	c7 44 24 0c 78 7b 10 	movl   $0xf0107b78,0xc(%esp)
f0102e83:	f0 
f0102e84:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102e8b:	f0 
f0102e8c:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102e93:	00 
f0102e94:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102e9b:	e8 a0 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ea0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ea6:	39 fe                	cmp    %edi,%esi
f0102ea8:	72 c1                	jb     f0102e6b <mem_init+0x1a43>
f0102eaa:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102eaf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102eb2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102eb5:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102eb8:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ebe:	89 c6                	mov    %eax,%esi
f0102ec0:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102ec6:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102ecc:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ecf:	89 da                	mov    %ebx,%edx
f0102ed1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ed4:	e8 13 dc ff ff       	call   f0100aec <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ed9:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ee0:	77 23                	ja     f0102f05 <mem_init+0x1add>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ee2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ee5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ee9:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0102ef0:	f0 
f0102ef1:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102ef8:	00 
f0102ef9:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102f00:	e8 3b d1 ff ff       	call   f0100040 <_panic>
f0102f05:	39 f0                	cmp    %esi,%eax
f0102f07:	74 24                	je     f0102f2d <mem_init+0x1b05>
f0102f09:	c7 44 24 0c a0 7b 10 	movl   $0xf0107ba0,0xc(%esp)
f0102f10:	f0 
f0102f11:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102f18:	f0 
f0102f19:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102f20:	00 
f0102f21:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102f28:	e8 13 d1 ff ff       	call   f0100040 <_panic>
f0102f2d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f33:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f39:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f3c:	0f 85 55 05 00 00    	jne    f0103497 <mem_init+0x206f>
f0102f42:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f47:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102f4a:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102f4d:	89 f0                	mov    %esi,%eax
f0102f4f:	e8 98 db ff ff       	call   f0100aec <check_va2pa>
f0102f54:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f57:	74 24                	je     f0102f7d <mem_init+0x1b55>
f0102f59:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f0102f60:	f0 
f0102f61:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102f68:	f0 
f0102f69:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102f70:	00 
f0102f71:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102f78:	e8 c3 d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f83:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f89:	75 bf                	jne    f0102f4a <mem_init+0x1b22>
f0102f8b:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102f91:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f98:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102f9e:	0f 85 0e ff ff ff    	jne    f0102eb2 <mem_init+0x1a8a>
f0102fa4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa7:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102fac:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102fb2:	83 fa 04             	cmp    $0x4,%edx
f0102fb5:	77 2e                	ja     f0102fe5 <mem_init+0x1bbd>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102fb7:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102fbb:	0f 85 aa 00 00 00    	jne    f010306b <mem_init+0x1c43>
f0102fc1:	c7 44 24 0c f8 7f 10 	movl   $0xf0107ff8,0xc(%esp)
f0102fc8:	f0 
f0102fc9:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0102fd0:	f0 
f0102fd1:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0102fd8:	00 
f0102fd9:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0102fe0:	e8 5b d0 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102fe5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fea:	76 55                	jbe    f0103041 <mem_init+0x1c19>
				assert(pgdir[i] & PTE_P);
f0102fec:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102fef:	f6 c2 01             	test   $0x1,%dl
f0102ff2:	75 24                	jne    f0103018 <mem_init+0x1bf0>
f0102ff4:	c7 44 24 0c f8 7f 10 	movl   $0xf0107ff8,0xc(%esp)
f0102ffb:	f0 
f0102ffc:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103003:	f0 
f0103004:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f010300b:	00 
f010300c:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103013:	e8 28 d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0103018:	f6 c2 02             	test   $0x2,%dl
f010301b:	75 4e                	jne    f010306b <mem_init+0x1c43>
f010301d:	c7 44 24 0c 09 80 10 	movl   $0xf0108009,0xc(%esp)
f0103024:	f0 
f0103025:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010302c:	f0 
f010302d:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0103034:	00 
f0103035:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010303c:	e8 ff cf ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103041:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103045:	74 24                	je     f010306b <mem_init+0x1c43>
f0103047:	c7 44 24 0c 1a 80 10 	movl   $0xf010801a,0xc(%esp)
f010304e:	f0 
f010304f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103056:	f0 
f0103057:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f010305e:	00 
f010305f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103066:	e8 d5 cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010306b:	40                   	inc    %eax
f010306c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103071:	0f 85 35 ff ff ff    	jne    f0102fac <mem_init+0x1b84>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103077:	c7 04 24 0c 7c 10 f0 	movl   $0xf0107c0c,(%esp)
f010307e:	e8 93 0f 00 00       	call   f0104016 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103083:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103088:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010308d:	77 20                	ja     f01030af <mem_init+0x1c87>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010308f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103093:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f010309a:	f0 
f010309b:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
f01030a2:	00 
f01030a3:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01030aa:	e8 91 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030af:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01030b4:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01030b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01030bc:	e8 c1 da ff ff       	call   f0100b82 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030c1:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01030c4:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030c9:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030cc:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030d6:	e8 e2 de ff ff       	call   f0100fbd <page_alloc>
f01030db:	89 c6                	mov    %eax,%esi
f01030dd:	85 c0                	test   %eax,%eax
f01030df:	75 24                	jne    f0103105 <mem_init+0x1cdd>
f01030e1:	c7 44 24 0c 04 7e 10 	movl   $0xf0107e04,0xc(%esp)
f01030e8:	f0 
f01030e9:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01030f0:	f0 
f01030f1:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f01030f8:	00 
f01030f9:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103100:	e8 3b cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103105:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010310c:	e8 ac de ff ff       	call   f0100fbd <page_alloc>
f0103111:	89 c7                	mov    %eax,%edi
f0103113:	85 c0                	test   %eax,%eax
f0103115:	75 24                	jne    f010313b <mem_init+0x1d13>
f0103117:	c7 44 24 0c 1a 7e 10 	movl   $0xf0107e1a,0xc(%esp)
f010311e:	f0 
f010311f:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103126:	f0 
f0103127:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f010312e:	00 
f010312f:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103136:	e8 05 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010313b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103142:	e8 76 de ff ff       	call   f0100fbd <page_alloc>
f0103147:	89 c3                	mov    %eax,%ebx
f0103149:	85 c0                	test   %eax,%eax
f010314b:	75 24                	jne    f0103171 <mem_init+0x1d49>
f010314d:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f0103154:	f0 
f0103155:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010315c:	f0 
f010315d:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f0103164:	00 
f0103165:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010316c:	e8 cf ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103171:	89 34 24             	mov    %esi,(%esp)
f0103174:	e8 c8 de ff ff       	call   f0101041 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103179:	89 f8                	mov    %edi,%eax
f010317b:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0103181:	c1 f8 03             	sar    $0x3,%eax
f0103184:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103187:	89 c2                	mov    %eax,%edx
f0103189:	c1 ea 0c             	shr    $0xc,%edx
f010318c:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0103192:	72 20                	jb     f01031b4 <mem_init+0x1d8c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103194:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103198:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f010319f:	f0 
f01031a0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031a7:	00 
f01031a8:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f01031af:	e8 8c ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01031b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031bb:	00 
f01031bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031c3:	00 
	return (void *)(pa + KERNBASE);
f01031c4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031c9:	89 04 24             	mov    %eax,(%esp)
f01031cc:	e8 8d 2f 00 00       	call   f010615e <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031d1:	89 d8                	mov    %ebx,%eax
f01031d3:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01031d9:	c1 f8 03             	sar    $0x3,%eax
f01031dc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031df:	89 c2                	mov    %eax,%edx
f01031e1:	c1 ea 0c             	shr    $0xc,%edx
f01031e4:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f01031ea:	72 20                	jb     f010320c <mem_init+0x1de4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031f0:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01031f7:	f0 
f01031f8:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031ff:	00 
f0103200:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0103207:	e8 34 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010320c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103213:	00 
f0103214:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010321b:	00 
	return (void *)(pa + KERNBASE);
f010321c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103221:	89 04 24             	mov    %eax,(%esp)
f0103224:	e8 35 2f 00 00       	call   f010615e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103229:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103230:	00 
f0103231:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103238:	00 
f0103239:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010323d:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0103242:	89 04 24             	mov    %eax,(%esp)
f0103245:	e8 e6 e0 ff ff       	call   f0101330 <page_insert>
	assert(pp1->pp_ref == 1);
f010324a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010324f:	74 24                	je     f0103275 <mem_init+0x1e4d>
f0103251:	c7 44 24 0c 01 7f 10 	movl   $0xf0107f01,0xc(%esp)
f0103258:	f0 
f0103259:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103260:	f0 
f0103261:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f0103268:	00 
f0103269:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103270:	e8 cb cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103275:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010327c:	01 01 01 
f010327f:	74 24                	je     f01032a5 <mem_init+0x1e7d>
f0103281:	c7 44 24 0c 2c 7c 10 	movl   $0xf0107c2c,0xc(%esp)
f0103288:	f0 
f0103289:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103290:	f0 
f0103291:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f0103298:	00 
f0103299:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01032a0:	e8 9b cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01032a5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032ac:	00 
f01032ad:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032b4:	00 
f01032b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032b9:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01032be:	89 04 24             	mov    %eax,(%esp)
f01032c1:	e8 6a e0 ff ff       	call   f0101330 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032c6:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032cd:	02 02 02 
f01032d0:	74 24                	je     f01032f6 <mem_init+0x1ece>
f01032d2:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f01032d9:	f0 
f01032da:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01032e1:	f0 
f01032e2:	c7 44 24 04 98 04 00 	movl   $0x498,0x4(%esp)
f01032e9:	00 
f01032ea:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01032f1:	e8 4a cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032f6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032fb:	74 24                	je     f0103321 <mem_init+0x1ef9>
f01032fd:	c7 44 24 0c 23 7f 10 	movl   $0xf0107f23,0xc(%esp)
f0103304:	f0 
f0103305:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010330c:	f0 
f010330d:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0103314:	00 
f0103315:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010331c:	e8 1f cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103321:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103326:	74 24                	je     f010334c <mem_init+0x1f24>
f0103328:	c7 44 24 0c 8d 7f 10 	movl   $0xf0107f8d,0xc(%esp)
f010332f:	f0 
f0103330:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103337:	f0 
f0103338:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f010333f:	00 
f0103340:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103347:	e8 f4 cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010334c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103353:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103356:	89 d8                	mov    %ebx,%eax
f0103358:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f010335e:	c1 f8 03             	sar    $0x3,%eax
f0103361:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103364:	89 c2                	mov    %eax,%edx
f0103366:	c1 ea 0c             	shr    $0xc,%edx
f0103369:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f010336f:	72 20                	jb     f0103391 <mem_init+0x1f69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103371:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103375:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f010337c:	f0 
f010337d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103384:	00 
f0103385:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f010338c:	e8 af cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103391:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103398:	03 03 03 
f010339b:	74 24                	je     f01033c1 <mem_init+0x1f99>
f010339d:	c7 44 24 0c 74 7c 10 	movl   $0xf0107c74,0xc(%esp)
f01033a4:	f0 
f01033a5:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01033ac:	f0 
f01033ad:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f01033b4:	00 
f01033b5:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01033bc:	e8 7f cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033c1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033c8:	00 
f01033c9:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01033ce:	89 04 24             	mov    %eax,(%esp)
f01033d1:	e8 ed de ff ff       	call   f01012c3 <page_remove>
	assert(pp2->pp_ref == 0);
f01033d6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01033db:	74 24                	je     f0103401 <mem_init+0x1fd9>
f01033dd:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f01033e4:	f0 
f01033e5:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f01033ec:	f0 
f01033ed:	c7 44 24 04 9e 04 00 	movl   $0x49e,0x4(%esp)
f01033f4:	00 
f01033f5:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f01033fc:	e8 3f cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103401:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0103406:	8b 08                	mov    (%eax),%ecx
f0103408:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010340e:	89 f2                	mov    %esi,%edx
f0103410:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0103416:	c1 fa 03             	sar    $0x3,%edx
f0103419:	c1 e2 0c             	shl    $0xc,%edx
f010341c:	39 d1                	cmp    %edx,%ecx
f010341e:	74 24                	je     f0103444 <mem_init+0x201c>
f0103420:	c7 44 24 0c fc 75 10 	movl   $0xf01075fc,0xc(%esp)
f0103427:	f0 
f0103428:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f010342f:	f0 
f0103430:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f0103437:	00 
f0103438:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f010343f:	e8 fc cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103444:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010344a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010344f:	74 24                	je     f0103475 <mem_init+0x204d>
f0103451:	c7 44 24 0c 12 7f 10 	movl   $0xf0107f12,0xc(%esp)
f0103458:	f0 
f0103459:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0103460:	f0 
f0103461:	c7 44 24 04 a3 04 00 	movl   $0x4a3,0x4(%esp)
f0103468:	00 
f0103469:	c7 04 24 01 7d 10 f0 	movl   $0xf0107d01,(%esp)
f0103470:	e8 cb cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103475:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010347b:	89 34 24             	mov    %esi,(%esp)
f010347e:	e8 be db ff ff       	call   f0101041 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103483:	c7 04 24 a0 7c 10 f0 	movl   $0xf0107ca0,(%esp)
f010348a:	e8 87 0b 00 00       	call   f0104016 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010348f:	83 c4 3c             	add    $0x3c,%esp
f0103492:	5b                   	pop    %ebx
f0103493:	5e                   	pop    %esi
f0103494:	5f                   	pop    %edi
f0103495:	5d                   	pop    %ebp
f0103496:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103497:	89 da                	mov    %ebx,%edx
f0103499:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010349c:	e8 4b d6 ff ff       	call   f0100aec <check_va2pa>
f01034a1:	e9 5f fa ff ff       	jmp    f0102f05 <mem_init+0x1add>

f01034a6 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01034a6:	55                   	push   %ebp
f01034a7:	89 e5                	mov    %esp,%ebp
f01034a9:	57                   	push   %edi
f01034aa:	56                   	push   %esi
f01034ab:	53                   	push   %ebx
f01034ac:	83 ec 2c             	sub    $0x2c,%esp
f01034af:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE);
f01034b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034b5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        uint32_t end = (uint32_t) ROUNDUP(va+len,PGSIZE);
f01034bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034be:	03 45 10             	add    0x10(%ebp),%eax
f01034c1:	05 ff 0f 00 00       	add    $0xfff,%eax
f01034c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        uint32_t i;
        perm = perm | PTE_P | PTE_U ;
f01034ce:	8b 7d 14             	mov    0x14(%ebp),%edi
f01034d1:	83 cf 05             	or     $0x5,%edi
        for(i = begin; i < end ; i+= PGSIZE){
f01034d4:	eb 61                	jmp    f0103537 <user_mem_check+0x91>
            if(i >= ULIM){
f01034d6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01034dc:	76 16                	jbe    f01034f4 <user_mem_check+0x4e>
                //user_mem_check_addr = i;  !!!
                user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f01034de:	89 d8                	mov    %ebx,%eax
f01034e0:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01034e3:	73 03                	jae    f01034e8 <user_mem_check+0x42>
f01034e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034e8:	a3 44 12 33 f0       	mov    %eax,0xf0331244
                //panic("user_mem_check fail at va more or equal to ULIM!\n");
                return -E_FAULT;
f01034ed:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034f2:	eb 4d                	jmp    f0103541 <user_mem_check+0x9b>
            }
            pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f01034f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034fb:	00 
f01034fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103500:	8b 46 60             	mov    0x60(%esi),%eax
f0103503:	89 04 24             	mov    %eax,(%esp)
f0103506:	e8 96 db ff ff       	call   f01010a1 <pgdir_walk>
            if(pte == NULL || !(*pte & PTE_P) || (*pte & perm) != perm){
f010350b:	85 c0                	test   %eax,%eax
f010350d:	74 0c                	je     f010351b <user_mem_check+0x75>
f010350f:	8b 00                	mov    (%eax),%eax
f0103511:	a8 01                	test   $0x1,%al
f0103513:	74 06                	je     f010351b <user_mem_check+0x75>
f0103515:	21 f8                	and    %edi,%eax
f0103517:	39 c7                	cmp    %eax,%edi
f0103519:	74 16                	je     f0103531 <user_mem_check+0x8b>
                //panic("user_mem_check fail at pte!\n");
                //user_mem_check_addr = i;
                user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f010351b:	89 d8                	mov    %ebx,%eax
f010351d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103520:	73 03                	jae    f0103525 <user_mem_check+0x7f>
f0103522:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103525:	a3 44 12 33 f0       	mov    %eax,0xf0331244
                return -E_FAULT;
f010352a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010352f:	eb 10                	jmp    f0103541 <user_mem_check+0x9b>
	// LAB 3: Your code here.
        uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE);
        uint32_t end = (uint32_t) ROUNDUP(va+len,PGSIZE);
        uint32_t i;
        perm = perm | PTE_P | PTE_U ;
        for(i = begin; i < end ; i+= PGSIZE){
f0103531:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103537:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010353a:	72 9a                	jb     f01034d6 <user_mem_check+0x30>
                user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
                return -E_FAULT;
            }
            i = ROUNDDOWN(i,PGSIZE);
        }
	return 0;
f010353c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103541:	83 c4 2c             	add    $0x2c,%esp
f0103544:	5b                   	pop    %ebx
f0103545:	5e                   	pop    %esi
f0103546:	5f                   	pop    %edi
f0103547:	5d                   	pop    %ebp
f0103548:	c3                   	ret    

f0103549 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103549:	55                   	push   %ebp
f010354a:	89 e5                	mov    %esp,%ebp
f010354c:	53                   	push   %ebx
f010354d:	83 ec 14             	sub    $0x14,%esp
f0103550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103553:	8b 45 14             	mov    0x14(%ebp),%eax
f0103556:	83 c8 04             	or     $0x4,%eax
f0103559:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010355d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103560:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103564:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103567:	89 44 24 04          	mov    %eax,0x4(%esp)
f010356b:	89 1c 24             	mov    %ebx,(%esp)
f010356e:	e8 33 ff ff ff       	call   f01034a6 <user_mem_check>
f0103573:	85 c0                	test   %eax,%eax
f0103575:	79 24                	jns    f010359b <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103577:	a1 44 12 33 f0       	mov    0xf0331244,%eax
f010357c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103580:	8b 43 48             	mov    0x48(%ebx),%eax
f0103583:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103587:	c7 04 24 cc 7c 10 f0 	movl   $0xf0107ccc,(%esp)
f010358e:	e8 83 0a 00 00       	call   f0104016 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103593:	89 1c 24             	mov    %ebx,(%esp)
f0103596:	e8 3e 07 00 00       	call   f0103cd9 <env_destroy>
	}
}
f010359b:	83 c4 14             	add    $0x14,%esp
f010359e:	5b                   	pop    %ebx
f010359f:	5d                   	pop    %ebp
f01035a0:	c3                   	ret    
f01035a1:	00 00                	add    %al,(%eax)
	...

f01035a4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01035a4:	55                   	push   %ebp
f01035a5:	89 e5                	mov    %esp,%ebp
f01035a7:	57                   	push   %edi
f01035a8:	56                   	push   %esi
f01035a9:	53                   	push   %ebx
f01035aa:	83 ec 1c             	sub    $0x1c,%esp
f01035ad:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
      
        //cprintf("region_alloc\n");
        void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f01035af:	89 d3                	mov    %edx,%ebx
f01035b1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01035b7:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01035be:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        for (; begin < end; begin += PGSIZE) {
f01035c4:	eb 4d                	jmp    f0103613 <region_alloc+0x6f>
            struct PageInfo *pg = page_alloc(0);    
f01035c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035cd:	e8 eb d9 ff ff       	call   f0100fbd <page_alloc>
            if (!pg) //not initialized
f01035d2:	85 c0                	test   %eax,%eax
f01035d4:	75 1c                	jne    f01035f2 <region_alloc+0x4e>
                panic("region_alloc failed!");
f01035d6:	c7 44 24 08 28 80 10 	movl   $0xf0108028,0x8(%esp)
f01035dd:	f0 
f01035de:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f01035e5:	00 
f01035e6:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f01035ed:	e8 4e ca ff ff       	call   f0100040 <_panic>
            page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);                                 
f01035f2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035f9:	00 
f01035fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103602:	8b 46 60             	mov    0x60(%esi),%eax
f0103605:	89 04 24             	mov    %eax,(%esp)
f0103608:	e8 23 dd ff ff       	call   f0101330 <page_insert>
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
      
        //cprintf("region_alloc\n");
        void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
        for (; begin < end; begin += PGSIZE) {
f010360d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103613:	39 fb                	cmp    %edi,%ebx
f0103615:	72 af                	jb     f01035c6 <region_alloc+0x22>
            struct PageInfo *pg = page_alloc(0);    
            if (!pg) //not initialized
                panic("region_alloc failed!");
            page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);                                 
        }
}
f0103617:	83 c4 1c             	add    $0x1c,%esp
f010361a:	5b                   	pop    %ebx
f010361b:	5e                   	pop    %esi
f010361c:	5f                   	pop    %edi
f010361d:	5d                   	pop    %ebp
f010361e:	c3                   	ret    

f010361f <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010361f:	55                   	push   %ebp
f0103620:	89 e5                	mov    %esp,%ebp
f0103622:	57                   	push   %edi
f0103623:	56                   	push   %esi
f0103624:	53                   	push   %ebx
f0103625:	83 ec 0c             	sub    $0xc,%esp
f0103628:	8b 45 08             	mov    0x8(%ebp),%eax
f010362b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010362e:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103631:	85 c0                	test   %eax,%eax
f0103633:	75 24                	jne    f0103659 <envid2env+0x3a>
		*env_store = curenv;
f0103635:	e8 52 31 00 00       	call   f010678c <cpunum>
f010363a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103641:	29 c2                	sub    %eax,%edx
f0103643:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103646:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f010364d:	89 06                	mov    %eax,(%esi)
		return 0;
f010364f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103654:	e9 84 00 00 00       	jmp    f01036dd <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103659:	89 c3                	mov    %eax,%ebx
f010365b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103661:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103668:	c1 e3 07             	shl    $0x7,%ebx
f010366b:	29 cb                	sub    %ecx,%ebx
f010366d:	03 1d 48 12 33 f0    	add    0xf0331248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103673:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103677:	74 05                	je     f010367e <envid2env+0x5f>
f0103679:	39 43 48             	cmp    %eax,0x48(%ebx)
f010367c:	74 0d                	je     f010368b <envid2env+0x6c>
		*env_store = 0;
f010367e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103684:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103689:	eb 52                	jmp    f01036dd <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010368b:	84 d2                	test   %dl,%dl
f010368d:	74 47                	je     f01036d6 <envid2env+0xb7>
f010368f:	e8 f8 30 00 00       	call   f010678c <cpunum>
f0103694:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010369b:	29 c2                	sub    %eax,%edx
f010369d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036a0:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f01036a7:	74 2d                	je     f01036d6 <envid2env+0xb7>
f01036a9:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01036ac:	e8 db 30 00 00       	call   f010678c <cpunum>
f01036b1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036b8:	29 c2                	sub    %eax,%edx
f01036ba:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036bd:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01036c4:	3b 78 48             	cmp    0x48(%eax),%edi
f01036c7:	74 0d                	je     f01036d6 <envid2env+0xb7>
		*env_store = 0;
f01036c9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036cf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036d4:	eb 07                	jmp    f01036dd <envid2env+0xbe>
	}

	*env_store = e;
f01036d6:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036dd:	83 c4 0c             	add    $0xc,%esp
f01036e0:	5b                   	pop    %ebx
f01036e1:	5e                   	pop    %esi
f01036e2:	5f                   	pop    %edi
f01036e3:	5d                   	pop    %ebp
f01036e4:	c3                   	ret    

f01036e5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036e5:	55                   	push   %ebp
f01036e6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036e8:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f01036ed:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036f0:	b8 23 00 00 00       	mov    $0x23,%eax
f01036f5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036f7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036f9:	b0 10                	mov    $0x10,%al
f01036fb:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036fd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036ff:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103701:	ea 08 37 10 f0 08 00 	ljmp   $0x8,$0xf0103708
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103708:	b0 00                	mov    $0x0,%al
f010370a:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010370d:	5d                   	pop    %ebp
f010370e:	c3                   	ret    

f010370f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010370f:	55                   	push   %ebp
f0103710:	89 e5                	mov    %esp,%ebp
f0103712:	56                   	push   %esi
f0103713:	53                   	push   %ebx
	// LAB 3: Your code here.
        //cprintf("env_init:\n");
        //cprintf("NENV: %d\n",NENV);
        int i;
        for(i = NENV - 1;i >= 0; i--){
            envs[i].env_id = 0;
f0103714:	8b 35 48 12 33 f0    	mov    0xf0331248,%esi
f010371a:	8b 0d 4c 12 33 f0    	mov    0xf033124c,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103720:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
	// Set up envs array
	// LAB 3: Your code here.
        //cprintf("env_init:\n");
        //cprintf("NENV: %d\n",NENV);
        int i;
        for(i = NENV - 1;i >= 0; i--){
f0103726:	ba ff 03 00 00       	mov    $0x3ff,%edx
f010372b:	eb 02                	jmp    f010372f <env_init+0x20>
            envs[i].env_id = 0;
            envs[i].env_link = env_free_list;
            env_free_list = &envs[i];
f010372d:	89 d9                	mov    %ebx,%ecx
	// LAB 3: Your code here.
        //cprintf("env_init:\n");
        //cprintf("NENV: %d\n",NENV);
        int i;
        for(i = NENV - 1;i >= 0; i--){
            envs[i].env_id = 0;
f010372f:	89 c3                	mov    %eax,%ebx
f0103731:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
            envs[i].env_link = env_free_list;
f0103738:	89 48 44             	mov    %ecx,0x44(%eax)
	// Set up envs array
	// LAB 3: Your code here.
        //cprintf("env_init:\n");
        //cprintf("NENV: %d\n",NENV);
        int i;
        for(i = NENV - 1;i >= 0; i--){
f010373b:	4a                   	dec    %edx
f010373c:	83 e8 7c             	sub    $0x7c,%eax
f010373f:	83 fa ff             	cmp    $0xffffffff,%edx
f0103742:	75 e9                	jne    f010372d <env_init+0x1e>
f0103744:	89 35 4c 12 33 f0    	mov    %esi,0xf033124c
            envs[i].env_link = env_free_list;
            env_free_list = &envs[i];
        }

	// Per-CPU part of the initialization
	env_init_percpu();
f010374a:	e8 96 ff ff ff       	call   f01036e5 <env_init_percpu>
}
f010374f:	5b                   	pop    %ebx
f0103750:	5e                   	pop    %esi
f0103751:	5d                   	pop    %ebp
f0103752:	c3                   	ret    

f0103753 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103753:	55                   	push   %ebp
f0103754:	89 e5                	mov    %esp,%ebp
f0103756:	56                   	push   %esi
f0103757:	53                   	push   %ebx
f0103758:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010375b:	8b 1d 4c 12 33 f0    	mov    0xf033124c,%ebx
f0103761:	85 db                	test   %ebx,%ebx
f0103763:	0f 84 bb 01 00 00    	je     f0103924 <env_alloc+0x1d1>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103769:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103770:	e8 48 d8 ff ff       	call   f0100fbd <page_alloc>
f0103775:	85 c0                	test   %eax,%eax
f0103777:	0f 84 ae 01 00 00    	je     f010392b <env_alloc+0x1d8>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

        p->pp_ref++;
f010377d:	66 ff 40 04          	incw   0x4(%eax)
f0103781:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0103787:	c1 f8 03             	sar    $0x3,%eax
f010378a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010378d:	89 c2                	mov    %eax,%edx
f010378f:	c1 ea 0c             	shr    $0xc,%edx
f0103792:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0103798:	72 20                	jb     f01037ba <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010379a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010379e:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01037a5:	f0 
f01037a6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037ad:	00 
f01037ae:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f01037b5:	e8 86 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037ba:	2d 00 00 00 10       	sub    $0x10000000,%eax
        e->env_pgdir = (pde_t *)page2kva(p);
f01037bf:	89 43 60             	mov    %eax,0x60(%ebx)
        memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01037c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037c9:	00 
f01037ca:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f01037d0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037d4:	89 04 24             	mov    %eax,(%esp)
f01037d7:	e8 36 2a 00 00       	call   f0106212 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037dc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037e4:	77 20                	ja     f0103806 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037ea:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01037f1:	f0 
f01037f2:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f01037f9:	00 
f01037fa:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103801:	e8 3a c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103806:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010380c:	83 ca 05             	or     $0x5,%edx
f010380f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103815:	8b 43 48             	mov    0x48(%ebx),%eax
f0103818:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010381d:	89 c1                	mov    %eax,%ecx
f010381f:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103825:	7f 05                	jg     f010382c <env_alloc+0xd9>
		generation = 1 << ENVGENSHIFT;
f0103827:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010382c:	89 d8                	mov    %ebx,%eax
f010382e:	2b 05 48 12 33 f0    	sub    0xf0331248,%eax
f0103834:	c1 f8 02             	sar    $0x2,%eax
f0103837:	89 c6                	mov    %eax,%esi
f0103839:	c1 e6 05             	shl    $0x5,%esi
f010383c:	89 c2                	mov    %eax,%edx
f010383e:	c1 e2 0a             	shl    $0xa,%edx
f0103841:	01 f2                	add    %esi,%edx
f0103843:	01 c2                	add    %eax,%edx
f0103845:	89 d6                	mov    %edx,%esi
f0103847:	c1 e6 0f             	shl    $0xf,%esi
f010384a:	01 f2                	add    %esi,%edx
f010384c:	c1 e2 05             	shl    $0x5,%edx
f010384f:	01 d0                	add    %edx,%eax
f0103851:	f7 d8                	neg    %eax
f0103853:	09 c1                	or     %eax,%ecx
f0103855:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103858:	8b 45 0c             	mov    0xc(%ebp),%eax
f010385b:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010385e:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103865:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010386c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103873:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010387a:	00 
f010387b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103882:	00 
f0103883:	89 1c 24             	mov    %ebx,(%esp)
f0103886:	e8 d3 28 00 00       	call   f010615e <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010388b:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103891:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103897:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010389d:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038a4:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

        e->env_tf.tf_eflags |= FL_IF;
f01038aa:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01038b1:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01038b8:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01038bc:	8b 43 44             	mov    0x44(%ebx),%eax
f01038bf:	a3 4c 12 33 f0       	mov    %eax,0xf033124c
	*newenv_store = e;
f01038c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01038c7:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038c9:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038cc:	e8 bb 2e 00 00       	call   f010678c <cpunum>
f01038d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038d8:	29 c2                	sub    %eax,%edx
f01038da:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038dd:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f01038e4:	00 
f01038e5:	74 1d                	je     f0103904 <env_alloc+0x1b1>
f01038e7:	e8 a0 2e 00 00       	call   f010678c <cpunum>
f01038ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038f3:	29 c2                	sub    %eax,%edx
f01038f5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038f8:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01038ff:	8b 40 48             	mov    0x48(%eax),%eax
f0103902:	eb 05                	jmp    f0103909 <env_alloc+0x1b6>
f0103904:	b8 00 00 00 00       	mov    $0x0,%eax
f0103909:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010390d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103911:	c7 04 24 48 80 10 f0 	movl   $0xf0108048,(%esp)
f0103918:	e8 f9 06 00 00       	call   f0104016 <cprintf>
	return 0;
f010391d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103922:	eb 0c                	jmp    f0103930 <env_alloc+0x1dd>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103924:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103929:	eb 05                	jmp    f0103930 <env_alloc+0x1dd>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010392b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103930:	83 c4 10             	add    $0x10,%esp
f0103933:	5b                   	pop    %ebx
f0103934:	5e                   	pop    %esi
f0103935:	5d                   	pop    %ebp
f0103936:	c3                   	ret    

f0103937 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103937:	55                   	push   %ebp
f0103938:	89 e5                	mov    %esp,%ebp
f010393a:	57                   	push   %edi
f010393b:	56                   	push   %esi
f010393c:	53                   	push   %ebx
f010393d:	83 ec 3c             	sub    $0x3c,%esp
f0103940:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
        //cprintf("env_create\n");
        struct Env *env_new_store;
        if(env_alloc(&env_new_store ,0) < 0)
f0103943:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010394a:	00 
f010394b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010394e:	89 04 24             	mov    %eax,(%esp)
f0103951:	e8 fd fd ff ff       	call   f0103753 <env_alloc>
f0103956:	85 c0                	test   %eax,%eax
f0103958:	79 1c                	jns    f0103976 <env_create+0x3f>
            panic("env_create fail at env_alloc!\n");
f010395a:	c7 44 24 08 98 80 10 	movl   $0xf0108098,0x8(%esp)
f0103961:	f0 
f0103962:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f0103969:	00 
f010396a:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103971:	e8 ca c6 ff ff       	call   f0100040 <_panic>
	//cprintf("env_create: curenv:%x\n", curenv);
        load_icode(env_new_store,binary);
f0103976:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103979:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        
        //cprintf("load_icode\n");
        struct Elf* elfhdr = (struct Elf *)binary;
        struct Proghdr *ph,*eph;

        if(elfhdr->e_magic != ELF_MAGIC)    //检查是否为ELF文件
f010397c:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103982:	74 1c                	je     f01039a0 <env_create+0x69>
            panic("load_icode fail at elf\n");
f0103984:	c7 44 24 08 5d 80 10 	movl   $0xf010805d,0x8(%esp)
f010398b:	f0 
f010398c:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f0103993:	00 
f0103994:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f010399b:	e8 a0 c6 ff ff       	call   f0100040 <_panic>

        ph = (struct Proghdr *)((uint8_t *) elfhdr + elfhdr->e_phoff);
f01039a0:	89 fb                	mov    %edi,%ebx
f01039a2:	03 5f 1c             	add    0x1c(%edi),%ebx
        eph = ph + elfhdr->e_phnum;
f01039a5:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039a9:	c1 e6 05             	shl    $0x5,%esi
f01039ac:	01 de                	add    %ebx,%esi

        lcr3(PADDR(e->env_pgdir));   //将页目录基址寄存器设置为新环境的参数
f01039ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039b1:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039b9:	77 20                	ja     f01039db <env_create+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039bf:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f01039c6:	f0 
f01039c7:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f01039ce:	00 
f01039cf:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f01039d6:	e8 65 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039db:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039e0:	0f 22 d8             	mov    %eax,%cr3
f01039e3:	eb 6c                	jmp    f0103a51 <env_create+0x11a>
        for( ;ph < eph;ph++){
            if(ph->p_type == ELF_PROG_LOAD){
f01039e5:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039e8:	75 64                	jne    f0103a4e <env_create+0x117>
	    //  You should only load segments with ph->p_type ==  ELF_PROG_LOAD
                if(ph->p_filesz > ph->p_memsz)
f01039ea:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039ed:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01039f0:	76 1c                	jbe    f0103a0e <env_create+0xd7>
                    panic("load_icode fail at filesz bigger than memsz\n");
f01039f2:	c7 44 24 08 b8 80 10 	movl   $0xf01080b8,0x8(%esp)
f01039f9:	f0 
f01039fa:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0103a01:	00 
f0103a02:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103a09:	e8 32 c6 ff ff       	call   f0100040 <_panic>

                region_alloc(e, (void *)ph->p_va, ph->p_memsz); 
f0103a0e:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a14:	e8 8b fb ff ff       	call   f01035a4 <region_alloc>
                memset((void *)ph->p_va, 0, ph->p_memsz);
f0103a19:	8b 43 14             	mov    0x14(%ebx),%eax
f0103a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a27:	00 
f0103a28:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a2b:	89 04 24             	mov    %eax,(%esp)
f0103a2e:	e8 2b 27 00 00       	call   f010615e <memset>
                memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103a33:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a36:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a3a:	89 f8                	mov    %edi,%eax
f0103a3c:	03 43 04             	add    0x4(%ebx),%eax
f0103a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a43:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a46:	89 04 24             	mov    %eax,(%esp)
f0103a49:	e8 5a 27 00 00       	call   f01061a8 <memmove>

        ph = (struct Proghdr *)((uint8_t *) elfhdr + elfhdr->e_phoff);
        eph = ph + elfhdr->e_phnum;

        lcr3(PADDR(e->env_pgdir));   //将页目录基址寄存器设置为新环境的参数
        for( ;ph < eph;ph++){
f0103a4e:	83 c3 20             	add    $0x20,%ebx
f0103a51:	39 de                	cmp    %ebx,%esi
f0103a53:	77 90                	ja     f01039e5 <env_create+0xae>
                region_alloc(e, (void *)ph->p_va, ph->p_memsz); 
                memset((void *)ph->p_va, 0, ph->p_memsz);
                memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
            }
        }
        lcr3(PADDR(kern_pgdir));    //将页目录基址寄存器设为原值
f0103a55:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a5a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a5f:	77 20                	ja     f0103a81 <env_create+0x14a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a65:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0103a6c:	f0 
f0103a6d:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0103a74:	00 
f0103a75:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103a7c:	e8 bf c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a81:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a86:	0f 22 d8             	mov    %eax,%cr3
        e->env_tf.tf_eip = elfhdr->e_entry; //将入口地址存入trapfame寄存器结构
f0103a89:	8b 47 18             	mov    0x18(%edi),%eax
f0103a8c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a8f:	89 42 30             	mov    %eax,0x30(%edx)
	// No:w map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
        
        region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103a92:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a97:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a9f:	e8 00 fb ff ff       	call   f01035a4 <region_alloc>
        if(env_alloc(&env_new_store ,0) < 0)
            panic("env_create fail at env_alloc!\n");
	//cprintf("env_create: curenv:%x\n", curenv);
        load_icode(env_new_store,binary);
        
        env_new_store->env_type = type;
f0103aa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103aaa:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103aad:	83 c4 3c             	add    $0x3c,%esp
f0103ab0:	5b                   	pop    %ebx
f0103ab1:	5e                   	pop    %esi
f0103ab2:	5f                   	pop    %edi
f0103ab3:	5d                   	pop    %ebp
f0103ab4:	c3                   	ret    

f0103ab5 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103ab5:	55                   	push   %ebp
f0103ab6:	89 e5                	mov    %esp,%ebp
f0103ab8:	57                   	push   %edi
f0103ab9:	56                   	push   %esi
f0103aba:	53                   	push   %ebx
f0103abb:	83 ec 2c             	sub    $0x2c,%esp
f0103abe:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ac1:	e8 c6 2c 00 00       	call   f010678c <cpunum>
f0103ac6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103acd:	29 c2                	sub    %eax,%edx
f0103acf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ad2:	39 3c 85 28 20 33 f0 	cmp    %edi,-0xfccdfd8(,%eax,4)
f0103ad9:	75 34                	jne    f0103b0f <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103adb:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ae0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ae5:	77 20                	ja     f0103b07 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aeb:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0103af2:	f0 
f0103af3:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f0103afa:	00 
f0103afb:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103b02:	e8 39 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b07:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b0c:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103b0f:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103b12:	e8 75 2c 00 00       	call   f010678c <cpunum>
f0103b17:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b1e:	29 c2                	sub    %eax,%edx
f0103b20:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b23:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0103b2a:	00 
f0103b2b:	74 1d                	je     f0103b4a <env_free+0x95>
f0103b2d:	e8 5a 2c 00 00       	call   f010678c <cpunum>
f0103b32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b39:	29 c2                	sub    %eax,%edx
f0103b3b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b3e:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103b45:	8b 40 48             	mov    0x48(%eax),%eax
f0103b48:	eb 05                	jmp    f0103b4f <env_free+0x9a>
f0103b4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b4f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b57:	c7 04 24 75 80 10 f0 	movl   $0xf0108075,(%esp)
f0103b5e:	e8 b3 04 00 00       	call   f0104016 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b63:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b6d:	c1 e0 02             	shl    $0x2,%eax
f0103b70:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b73:	8b 47 60             	mov    0x60(%edi),%eax
f0103b76:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b79:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103b7c:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b82:	0f 84 b6 00 00 00    	je     f0103c3e <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b88:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b8e:	89 f0                	mov    %esi,%eax
f0103b90:	c1 e8 0c             	shr    $0xc,%eax
f0103b93:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b96:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103b9c:	72 20                	jb     f0103bbe <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b9e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103ba2:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0103ba9:	f0 
f0103baa:	c7 44 24 04 bc 01 00 	movl   $0x1bc,0x4(%esp)
f0103bb1:	00 
f0103bb2:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103bb9:	e8 82 c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103bc1:	c1 e2 16             	shl    $0x16,%edx
f0103bc4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103bcc:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103bd3:	01 
f0103bd4:	74 17                	je     f0103bed <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bd6:	89 d8                	mov    %ebx,%eax
f0103bd8:	c1 e0 0c             	shl    $0xc,%eax
f0103bdb:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103bde:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be2:	8b 47 60             	mov    0x60(%edi),%eax
f0103be5:	89 04 24             	mov    %eax,(%esp)
f0103be8:	e8 d6 d6 ff ff       	call   f01012c3 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bed:	43                   	inc    %ebx
f0103bee:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bf4:	75 d6                	jne    f0103bcc <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103bf6:	8b 47 60             	mov    0x60(%edi),%eax
f0103bf9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103bfc:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c03:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103c06:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103c0c:	72 1c                	jb     f0103c2a <env_free+0x175>
		panic("pa2page called with invalid pa");
f0103c0e:	c7 44 24 08 a8 74 10 	movl   $0xf01074a8,0x8(%esp)
f0103c15:	f0 
f0103c16:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c1d:	00 
f0103c1e:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0103c25:	e8 16 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103c2d:	c1 e0 03             	shl    $0x3,%eax
f0103c30:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
		page_decref(pa2page(pa));
f0103c36:	89 04 24             	mov    %eax,(%esp)
f0103c39:	e8 43 d4 ff ff       	call   f0101081 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c3e:	ff 45 e0             	incl   -0x20(%ebp)
f0103c41:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c48:	0f 85 1c ff ff ff    	jne    f0103b6a <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c4e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c51:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c56:	77 20                	ja     f0103c78 <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c5c:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0103c63:	f0 
f0103c64:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
f0103c6b:	00 
f0103c6c:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103c73:	e8 c8 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c78:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c7f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c84:	c1 e8 0c             	shr    $0xc,%eax
f0103c87:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103c8d:	72 1c                	jb     f0103cab <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f0103c8f:	c7 44 24 08 a8 74 10 	movl   $0xf01074a8,0x8(%esp)
f0103c96:	f0 
f0103c97:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c9e:	00 
f0103c9f:	c7 04 24 0d 7d 10 f0 	movl   $0xf0107d0d,(%esp)
f0103ca6:	e8 95 c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103cab:	c1 e0 03             	shl    $0x3,%eax
f0103cae:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
	page_decref(pa2page(pa));
f0103cb4:	89 04 24             	mov    %eax,(%esp)
f0103cb7:	e8 c5 d3 ff ff       	call   f0101081 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103cbc:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103cc3:	a1 4c 12 33 f0       	mov    0xf033124c,%eax
f0103cc8:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103ccb:	89 3d 4c 12 33 f0    	mov    %edi,0xf033124c
}
f0103cd1:	83 c4 2c             	add    $0x2c,%esp
f0103cd4:	5b                   	pop    %ebx
f0103cd5:	5e                   	pop    %esi
f0103cd6:	5f                   	pop    %edi
f0103cd7:	5d                   	pop    %ebp
f0103cd8:	c3                   	ret    

f0103cd9 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103cd9:	55                   	push   %ebp
f0103cda:	89 e5                	mov    %esp,%ebp
f0103cdc:	53                   	push   %ebx
f0103cdd:	83 ec 14             	sub    $0x14,%esp
f0103ce0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103ce3:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103ce7:	75 23                	jne    f0103d0c <env_destroy+0x33>
f0103ce9:	e8 9e 2a 00 00       	call   f010678c <cpunum>
f0103cee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cf5:	29 c2                	sub    %eax,%edx
f0103cf7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cfa:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103d01:	74 09                	je     f0103d0c <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103d03:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103d0a:	eb 39                	jmp    f0103d45 <env_destroy+0x6c>
	}

	env_free(e);
f0103d0c:	89 1c 24             	mov    %ebx,(%esp)
f0103d0f:	e8 a1 fd ff ff       	call   f0103ab5 <env_free>

	if (curenv == e) {
f0103d14:	e8 73 2a 00 00       	call   f010678c <cpunum>
f0103d19:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d20:	29 c2                	sub    %eax,%edx
f0103d22:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d25:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103d2c:	75 17                	jne    f0103d45 <env_destroy+0x6c>
		curenv = NULL;
f0103d2e:	e8 59 2a 00 00       	call   f010678c <cpunum>
f0103d33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d36:	c7 80 28 20 33 f0 00 	movl   $0x0,-0xfccdfd8(%eax)
f0103d3d:	00 00 00 
		sched_yield();
f0103d40:	e8 49 11 00 00       	call   f0104e8e <sched_yield>
	}
}
f0103d45:	83 c4 14             	add    $0x14,%esp
f0103d48:	5b                   	pop    %ebx
f0103d49:	5d                   	pop    %ebp
f0103d4a:	c3                   	ret    

f0103d4b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d4b:	55                   	push   %ebp
f0103d4c:	89 e5                	mov    %esp,%ebp
f0103d4e:	53                   	push   %ebx
f0103d4f:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d52:	e8 35 2a 00 00       	call   f010678c <cpunum>
f0103d57:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d5e:	29 c2                	sub    %eax,%edx
f0103d60:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d63:	8b 1c 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%ebx
f0103d6a:	e8 1d 2a 00 00       	call   f010678c <cpunum>
f0103d6f:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d72:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d75:	61                   	popa   
f0103d76:	07                   	pop    %es
f0103d77:	1f                   	pop    %ds
f0103d78:	83 c4 08             	add    $0x8,%esp
f0103d7b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d7c:	c7 44 24 08 8b 80 10 	movl   $0xf010808b,0x8(%esp)
f0103d83:	f0 
f0103d84:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
f0103d8b:	00 
f0103d8c:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103d93:	e8 a8 c2 ff ff       	call   f0100040 <_panic>

f0103d98 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d98:	55                   	push   %ebp
f0103d99:	89 e5                	mov    %esp,%ebp
f0103d9b:	53                   	push   %ebx
f0103d9c:	83 ec 14             	sub    $0x14,%esp
f0103d9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
        i = 1;
    }*/
	//panic("env_run not yet implemented");
       // cprintf("env_run\n");
       // cprintf("curenv=%x e=%x,e->env_pgdir=%x\n",curenv,e,e->env_pgdir);
        if(curenv != e){
f0103da2:	e8 e5 29 00 00       	call   f010678c <cpunum>
f0103da7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dae:	29 c2                	sub    %eax,%edx
f0103db0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103db3:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103dba:	0f 84 e0 00 00 00    	je     f0103ea0 <env_run+0x108>
            if(curenv != NULL)
f0103dc0:	e8 c7 29 00 00       	call   f010678c <cpunum>
f0103dc5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103dcc:	29 c2                	sub    %eax,%edx
f0103dce:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103dd1:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0103dd8:	00 
f0103dd9:	74 29                	je     f0103e04 <env_run+0x6c>
                if(curenv->env_status == ENV_RUNNING)
f0103ddb:	e8 ac 29 00 00       	call   f010678c <cpunum>
f0103de0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103de3:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0103de9:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103ded:	75 15                	jne    f0103e04 <env_run+0x6c>
                    curenv->env_status = ENV_RUNNABLE;
f0103def:	e8 98 29 00 00       	call   f010678c <cpunum>
f0103df4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df7:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0103dfd:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
            curenv = e;
f0103e04:	e8 83 29 00 00       	call   f010678c <cpunum>
f0103e09:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e10:	29 c2                	sub    %eax,%edx
f0103e12:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e15:	89 1c 85 28 20 33 f0 	mov    %ebx,-0xfccdfd8(,%eax,4)
            curenv->env_status = ENV_RUNNING;
f0103e1c:	e8 6b 29 00 00       	call   f010678c <cpunum>
f0103e21:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e28:	29 c2                	sub    %eax,%edx
f0103e2a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e2d:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103e34:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
            curenv->env_runs++;
f0103e3b:	e8 4c 29 00 00       	call   f010678c <cpunum>
f0103e40:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e47:	29 c2                	sub    %eax,%edx
f0103e49:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e4c:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103e53:	ff 40 58             	incl   0x58(%eax)
           // cprintf("curenv->env_phdir = %x\n",curenv->env_pgdir);
            lcr3(PADDR(curenv->env_pgdir));
f0103e56:	e8 31 29 00 00       	call   f010678c <cpunum>
f0103e5b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e62:	29 c2                	sub    %eax,%edx
f0103e64:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e67:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103e6e:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e71:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e76:	77 20                	ja     f0103e98 <env_run+0x100>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e78:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e7c:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0103e83:	f0 
f0103e84:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
f0103e8b:	00 
f0103e8c:	c7 04 24 3d 80 10 f0 	movl   $0xf010803d,(%esp)
f0103e93:	e8 a8 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e98:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e9d:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ea0:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0103ea7:	e8 42 2c 00 00       	call   f0106aee <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103eac:	f3 90                	pause  
            //lcr3(curenv->env_cr3);
            // Restores the register values in the Trapframe with the 'iret' instruction.
        }
        unlock_kernel();
        env_pop_tf(&(curenv->env_tf));
f0103eae:	e8 d9 28 00 00       	call   f010678c <cpunum>
f0103eb3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103eba:	29 c2                	sub    %eax,%edx
f0103ebc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ebf:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103ec6:	89 04 24             	mov    %eax,(%esp)
f0103ec9:	e8 7d fe ff ff       	call   f0103d4b <env_pop_tf>
	...

f0103ed0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103ed0:	55                   	push   %ebp
f0103ed1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ed3:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ed8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103edb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103edc:	b2 71                	mov    $0x71,%dl
f0103ede:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103edf:	0f b6 c0             	movzbl %al,%eax
}
f0103ee2:	5d                   	pop    %ebp
f0103ee3:	c3                   	ret    

f0103ee4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103ee4:	55                   	push   %ebp
f0103ee5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ee7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103eec:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eef:	ee                   	out    %al,(%dx)
f0103ef0:	b2 71                	mov    $0x71,%dl
f0103ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ef5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103ef6:	5d                   	pop    %ebp
f0103ef7:	c3                   	ret    

f0103ef8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103ef8:	55                   	push   %ebp
f0103ef9:	89 e5                	mov    %esp,%ebp
f0103efb:	56                   	push   %esi
f0103efc:	53                   	push   %ebx
f0103efd:	83 ec 10             	sub    $0x10,%esp
f0103f00:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f03:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103f05:	66 a3 a8 93 12 f0    	mov    %ax,0xf01293a8
	if (!didinit)
f0103f0b:	80 3d 50 12 33 f0 00 	cmpb   $0x0,0xf0331250
f0103f12:	74 51                	je     f0103f65 <irq_setmask_8259A+0x6d>
f0103f14:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f19:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103f1a:	89 f0                	mov    %esi,%eax
f0103f1c:	66 c1 e8 08          	shr    $0x8,%ax
f0103f20:	b2 a1                	mov    $0xa1,%dl
f0103f22:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103f23:	c7 04 24 e5 80 10 f0 	movl   $0xf01080e5,(%esp)
f0103f2a:	e8 e7 00 00 00       	call   f0104016 <cprintf>
	for (i = 0; i < 16; i++)
f0103f2f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103f34:	0f b7 f6             	movzwl %si,%esi
f0103f37:	f7 d6                	not    %esi
f0103f39:	89 f0                	mov    %esi,%eax
f0103f3b:	88 d9                	mov    %bl,%cl
f0103f3d:	d3 f8                	sar    %cl,%eax
f0103f3f:	a8 01                	test   $0x1,%al
f0103f41:	74 10                	je     f0103f53 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103f43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f47:	c7 04 24 9b 85 10 f0 	movl   $0xf010859b,(%esp)
f0103f4e:	e8 c3 00 00 00       	call   f0104016 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103f53:	43                   	inc    %ebx
f0103f54:	83 fb 10             	cmp    $0x10,%ebx
f0103f57:	75 e0                	jne    f0103f39 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103f59:	c7 04 24 f6 7f 10 f0 	movl   $0xf0107ff6,(%esp)
f0103f60:	e8 b1 00 00 00       	call   f0104016 <cprintf>
}
f0103f65:	83 c4 10             	add    $0x10,%esp
f0103f68:	5b                   	pop    %ebx
f0103f69:	5e                   	pop    %esi
f0103f6a:	5d                   	pop    %ebp
f0103f6b:	c3                   	ret    

f0103f6c <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103f6c:	55                   	push   %ebp
f0103f6d:	89 e5                	mov    %esp,%ebp
f0103f6f:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103f72:	c6 05 50 12 33 f0 01 	movb   $0x1,0xf0331250
f0103f79:	ba 21 00 00 00       	mov    $0x21,%edx
f0103f7e:	b0 ff                	mov    $0xff,%al
f0103f80:	ee                   	out    %al,(%dx)
f0103f81:	b2 a1                	mov    $0xa1,%dl
f0103f83:	ee                   	out    %al,(%dx)
f0103f84:	b2 20                	mov    $0x20,%dl
f0103f86:	b0 11                	mov    $0x11,%al
f0103f88:	ee                   	out    %al,(%dx)
f0103f89:	b2 21                	mov    $0x21,%dl
f0103f8b:	b0 20                	mov    $0x20,%al
f0103f8d:	ee                   	out    %al,(%dx)
f0103f8e:	b0 04                	mov    $0x4,%al
f0103f90:	ee                   	out    %al,(%dx)
f0103f91:	b0 03                	mov    $0x3,%al
f0103f93:	ee                   	out    %al,(%dx)
f0103f94:	b2 a0                	mov    $0xa0,%dl
f0103f96:	b0 11                	mov    $0x11,%al
f0103f98:	ee                   	out    %al,(%dx)
f0103f99:	b2 a1                	mov    $0xa1,%dl
f0103f9b:	b0 28                	mov    $0x28,%al
f0103f9d:	ee                   	out    %al,(%dx)
f0103f9e:	b0 02                	mov    $0x2,%al
f0103fa0:	ee                   	out    %al,(%dx)
f0103fa1:	b0 01                	mov    $0x1,%al
f0103fa3:	ee                   	out    %al,(%dx)
f0103fa4:	b2 20                	mov    $0x20,%dl
f0103fa6:	b0 68                	mov    $0x68,%al
f0103fa8:	ee                   	out    %al,(%dx)
f0103fa9:	b0 0a                	mov    $0xa,%al
f0103fab:	ee                   	out    %al,(%dx)
f0103fac:	b2 a0                	mov    $0xa0,%dl
f0103fae:	b0 68                	mov    $0x68,%al
f0103fb0:	ee                   	out    %al,(%dx)
f0103fb1:	b0 0a                	mov    $0xa,%al
f0103fb3:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103fb4:	66 a1 a8 93 12 f0    	mov    0xf01293a8,%ax
f0103fba:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103fbe:	74 0b                	je     f0103fcb <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103fc0:	0f b7 c0             	movzwl %ax,%eax
f0103fc3:	89 04 24             	mov    %eax,(%esp)
f0103fc6:	e8 2d ff ff ff       	call   f0103ef8 <irq_setmask_8259A>
}
f0103fcb:	c9                   	leave  
f0103fcc:	c3                   	ret    
f0103fcd:	00 00                	add    %al,(%eax)
	...

f0103fd0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103fd0:	55                   	push   %ebp
f0103fd1:	89 e5                	mov    %esp,%ebp
f0103fd3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fd9:	89 04 24             	mov    %eax,(%esp)
f0103fdc:	e8 86 c7 ff ff       	call   f0100767 <cputchar>
	*cnt++;
}
f0103fe1:	c9                   	leave  
f0103fe2:	c3                   	ret    

f0103fe3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103fe3:	55                   	push   %ebp
f0103fe4:	89 e5                	mov    %esp,%ebp
f0103fe6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103fe9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ff3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ff7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ffa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ffe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104001:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104005:	c7 04 24 d0 3f 10 f0 	movl   $0xf0103fd0,(%esp)
f010400c:	e8 0d 1b 00 00       	call   f0105b1e <vprintfmt>
	return cnt;
}
f0104011:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104014:	c9                   	leave  
f0104015:	c3                   	ret    

f0104016 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104016:	55                   	push   %ebp
f0104017:	89 e5                	mov    %esp,%ebp
f0104019:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010401c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010401f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104023:	8b 45 08             	mov    0x8(%ebp),%eax
f0104026:	89 04 24             	mov    %eax,(%esp)
f0104029:	e8 b5 ff ff ff       	call   f0103fe3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010402e:	c9                   	leave  
f010402f:	c3                   	ret    

f0104030 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104030:	55                   	push   %ebp
f0104031:	89 e5                	mov    %esp,%ebp
f0104033:	57                   	push   %edi
f0104034:	56                   	push   %esi
f0104035:	53                   	push   %ebx
f0104036:	83 ec 0c             	sub    $0xc,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

        uint32_t current_cpu_id = cpunum();
f0104039:	e8 4e 27 00 00       	call   f010678c <cpunum>
f010403e:	89 c3                	mov    %eax,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//ts.ts_esp0 = KSTACKTOP;
	//ts.ts_ss0 = GD_KD;
        thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - current_cpu_id * (KSTKSIZE + KSTKGAP);
f0104040:	e8 47 27 00 00       	call   f010678c <cpunum>
f0104045:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010404c:	29 c2                	sub    %eax,%edx
f010404e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104051:	89 da                	mov    %ebx,%edx
f0104053:	f7 da                	neg    %edx
f0104055:	c1 e2 10             	shl    $0x10,%edx
f0104058:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010405e:	89 14 85 30 20 33 f0 	mov    %edx,-0xfccdfd0(,%eax,4)
        thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104065:	e8 22 27 00 00       	call   f010678c <cpunum>
f010406a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104071:	29 c2                	sub    %eax,%edx
f0104073:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104076:	66 c7 04 85 34 20 33 	movw   $0x10,-0xfccdfcc(,%eax,4)
f010407d:	f0 10 00 
         
	// Initialize the TSS slot of the gdt.
	//gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
	//				sizeof(struct Taskstate) - 1, 0);
	//gdt[GD_TSS0 >> 3].sd_s = 0;
	gdt[(GD_TSS0 >> 3) + current_cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0104080:	83 c3 05             	add    $0x5,%ebx
f0104083:	e8 04 27 00 00       	call   f010678c <cpunum>
f0104088:	89 c6                	mov    %eax,%esi
f010408a:	e8 fd 26 00 00       	call   f010678c <cpunum>
f010408f:	89 c7                	mov    %eax,%edi
f0104091:	e8 f6 26 00 00       	call   f010678c <cpunum>
f0104096:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f010409d:	f0 67 00 
f01040a0:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f01040a7:	29 f2                	sub    %esi,%edx
f01040a9:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01040ac:	8d 14 95 2c 20 33 f0 	lea    -0xfccdfd4(,%edx,4),%edx
f01040b3:	66 89 14 dd 42 93 12 	mov    %dx,-0xfed6cbe(,%ebx,8)
f01040ba:	f0 
f01040bb:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01040c2:	29 fa                	sub    %edi,%edx
f01040c4:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01040c7:	8d 14 95 2c 20 33 f0 	lea    -0xfccdfd4(,%edx,4),%edx
f01040ce:	c1 ea 10             	shr    $0x10,%edx
f01040d1:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f01040d8:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f01040df:	40 
f01040e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040e7:	29 c2                	sub    %eax,%edx
f01040e9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040ec:	8d 04 85 2c 20 33 f0 	lea    -0xfccdfd4(,%eax,4),%eax
f01040f3:	c1 e8 18             	shr    $0x18,%eax
f01040f6:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + current_cpu_id].sd_s = 0;
f01040fd:	c6 04 dd 45 93 12 f0 	movb   $0x89,-0xfed6cbb(,%ebx,8)
f0104104:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0104105:	e8 82 26 00 00       	call   f010678c <cpunum>
f010410a:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104111:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104114:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f0104119:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f010411c:	83 c4 0c             	add    $0xc,%esp
f010411f:	5b                   	pop    %ebx
f0104120:	5e                   	pop    %esi
f0104121:	5f                   	pop    %edi
f0104122:	5d                   	pop    %ebp
f0104123:	c3                   	ret    

f0104124 <trap_init>:
}


void
trap_init(void)
{
f0104124:	55                   	push   %ebp
f0104125:	89 e5                	mov    %esp,%ebp
f0104127:	83 ec 08             	sub    $0x8,%esp
        extern void irq12();
        extern void irq13();
        extern void irq14();
        extern void irq15();
        
        SETGATE(idt[0], 0, GD_KT, th0, 0);
f010412a:	b8 b4 4c 10 f0       	mov    $0xf0104cb4,%eax
f010412f:	66 a3 60 12 33 f0    	mov    %ax,0xf0331260
f0104135:	66 c7 05 62 12 33 f0 	movw   $0x8,0xf0331262
f010413c:	08 00 
f010413e:	c6 05 64 12 33 f0 00 	movb   $0x0,0xf0331264
f0104145:	c6 05 65 12 33 f0 8e 	movb   $0x8e,0xf0331265
f010414c:	c1 e8 10             	shr    $0x10,%eax
f010414f:	66 a3 66 12 33 f0    	mov    %ax,0xf0331266
        SETGATE(idt[1], 0, GD_KT, th1, 0);
f0104155:	b8 be 4c 10 f0       	mov    $0xf0104cbe,%eax
f010415a:	66 a3 68 12 33 f0    	mov    %ax,0xf0331268
f0104160:	66 c7 05 6a 12 33 f0 	movw   $0x8,0xf033126a
f0104167:	08 00 
f0104169:	c6 05 6c 12 33 f0 00 	movb   $0x0,0xf033126c
f0104170:	c6 05 6d 12 33 f0 8e 	movb   $0x8e,0xf033126d
f0104177:	c1 e8 10             	shr    $0x10,%eax
f010417a:	66 a3 6e 12 33 f0    	mov    %ax,0xf033126e
        SETGATE(idt[3], 0, GD_KT, th3, 3);
f0104180:	b8 c8 4c 10 f0       	mov    $0xf0104cc8,%eax
f0104185:	66 a3 78 12 33 f0    	mov    %ax,0xf0331278
f010418b:	66 c7 05 7a 12 33 f0 	movw   $0x8,0xf033127a
f0104192:	08 00 
f0104194:	c6 05 7c 12 33 f0 00 	movb   $0x0,0xf033127c
f010419b:	c6 05 7d 12 33 f0 ee 	movb   $0xee,0xf033127d
f01041a2:	c1 e8 10             	shr    $0x10,%eax
f01041a5:	66 a3 7e 12 33 f0    	mov    %ax,0xf033127e
        SETGATE(idt[4], 0, GD_KT, th4, 0);
f01041ab:	b8 d2 4c 10 f0       	mov    $0xf0104cd2,%eax
f01041b0:	66 a3 80 12 33 f0    	mov    %ax,0xf0331280
f01041b6:	66 c7 05 82 12 33 f0 	movw   $0x8,0xf0331282
f01041bd:	08 00 
f01041bf:	c6 05 84 12 33 f0 00 	movb   $0x0,0xf0331284
f01041c6:	c6 05 85 12 33 f0 8e 	movb   $0x8e,0xf0331285
f01041cd:	c1 e8 10             	shr    $0x10,%eax
f01041d0:	66 a3 86 12 33 f0    	mov    %ax,0xf0331286
        SETGATE(idt[5], 0, GD_KT, th5, 0);
f01041d6:	b8 dc 4c 10 f0       	mov    $0xf0104cdc,%eax
f01041db:	66 a3 88 12 33 f0    	mov    %ax,0xf0331288
f01041e1:	66 c7 05 8a 12 33 f0 	movw   $0x8,0xf033128a
f01041e8:	08 00 
f01041ea:	c6 05 8c 12 33 f0 00 	movb   $0x0,0xf033128c
f01041f1:	c6 05 8d 12 33 f0 8e 	movb   $0x8e,0xf033128d
f01041f8:	c1 e8 10             	shr    $0x10,%eax
f01041fb:	66 a3 8e 12 33 f0    	mov    %ax,0xf033128e
        SETGATE(idt[6], 0, GD_KT, th6, 0);
f0104201:	b8 e6 4c 10 f0       	mov    $0xf0104ce6,%eax
f0104206:	66 a3 90 12 33 f0    	mov    %ax,0xf0331290
f010420c:	66 c7 05 92 12 33 f0 	movw   $0x8,0xf0331292
f0104213:	08 00 
f0104215:	c6 05 94 12 33 f0 00 	movb   $0x0,0xf0331294
f010421c:	c6 05 95 12 33 f0 8e 	movb   $0x8e,0xf0331295
f0104223:	c1 e8 10             	shr    $0x10,%eax
f0104226:	66 a3 96 12 33 f0    	mov    %ax,0xf0331296
        SETGATE(idt[7], 0, GD_KT, th7, 0);
f010422c:	b8 f0 4c 10 f0       	mov    $0xf0104cf0,%eax
f0104231:	66 a3 98 12 33 f0    	mov    %ax,0xf0331298
f0104237:	66 c7 05 9a 12 33 f0 	movw   $0x8,0xf033129a
f010423e:	08 00 
f0104240:	c6 05 9c 12 33 f0 00 	movb   $0x0,0xf033129c
f0104247:	c6 05 9d 12 33 f0 8e 	movb   $0x8e,0xf033129d
f010424e:	c1 e8 10             	shr    $0x10,%eax
f0104251:	66 a3 9e 12 33 f0    	mov    %ax,0xf033129e
        SETGATE(idt[8], 0, GD_KT, th8, 0);
f0104257:	b8 fa 4c 10 f0       	mov    $0xf0104cfa,%eax
f010425c:	66 a3 a0 12 33 f0    	mov    %ax,0xf03312a0
f0104262:	66 c7 05 a2 12 33 f0 	movw   $0x8,0xf03312a2
f0104269:	08 00 
f010426b:	c6 05 a4 12 33 f0 00 	movb   $0x0,0xf03312a4
f0104272:	c6 05 a5 12 33 f0 8e 	movb   $0x8e,0xf03312a5
f0104279:	c1 e8 10             	shr    $0x10,%eax
f010427c:	66 a3 a6 12 33 f0    	mov    %ax,0xf03312a6
        SETGATE(idt[9], 0, GD_KT, th9, 0);
f0104282:	b8 02 4d 10 f0       	mov    $0xf0104d02,%eax
f0104287:	66 a3 a8 12 33 f0    	mov    %ax,0xf03312a8
f010428d:	66 c7 05 aa 12 33 f0 	movw   $0x8,0xf03312aa
f0104294:	08 00 
f0104296:	c6 05 ac 12 33 f0 00 	movb   $0x0,0xf03312ac
f010429d:	c6 05 ad 12 33 f0 8e 	movb   $0x8e,0xf03312ad
f01042a4:	c1 e8 10             	shr    $0x10,%eax
f01042a7:	66 a3 ae 12 33 f0    	mov    %ax,0xf03312ae
        SETGATE(idt[10], 0, GD_KT, th10, 0);
f01042ad:	b8 0c 4d 10 f0       	mov    $0xf0104d0c,%eax
f01042b2:	66 a3 b0 12 33 f0    	mov    %ax,0xf03312b0
f01042b8:	66 c7 05 b2 12 33 f0 	movw   $0x8,0xf03312b2
f01042bf:	08 00 
f01042c1:	c6 05 b4 12 33 f0 00 	movb   $0x0,0xf03312b4
f01042c8:	c6 05 b5 12 33 f0 8e 	movb   $0x8e,0xf03312b5
f01042cf:	c1 e8 10             	shr    $0x10,%eax
f01042d2:	66 a3 b6 12 33 f0    	mov    %ax,0xf03312b6
        SETGATE(idt[11], 0, GD_KT, th11, 0);
f01042d8:	b8 10 4d 10 f0       	mov    $0xf0104d10,%eax
f01042dd:	66 a3 b8 12 33 f0    	mov    %ax,0xf03312b8
f01042e3:	66 c7 05 ba 12 33 f0 	movw   $0x8,0xf03312ba
f01042ea:	08 00 
f01042ec:	c6 05 bc 12 33 f0 00 	movb   $0x0,0xf03312bc
f01042f3:	c6 05 bd 12 33 f0 8e 	movb   $0x8e,0xf03312bd
f01042fa:	c1 e8 10             	shr    $0x10,%eax
f01042fd:	66 a3 be 12 33 f0    	mov    %ax,0xf03312be
        SETGATE(idt[12], 0, GD_KT, th12, 0);
f0104303:	b8 14 4d 10 f0       	mov    $0xf0104d14,%eax
f0104308:	66 a3 c0 12 33 f0    	mov    %ax,0xf03312c0
f010430e:	66 c7 05 c2 12 33 f0 	movw   $0x8,0xf03312c2
f0104315:	08 00 
f0104317:	c6 05 c4 12 33 f0 00 	movb   $0x0,0xf03312c4
f010431e:	c6 05 c5 12 33 f0 8e 	movb   $0x8e,0xf03312c5
f0104325:	c1 e8 10             	shr    $0x10,%eax
f0104328:	66 a3 c6 12 33 f0    	mov    %ax,0xf03312c6
        SETGATE(idt[13], 0, GD_KT, th13, 0);
f010432e:	b8 18 4d 10 f0       	mov    $0xf0104d18,%eax
f0104333:	66 a3 c8 12 33 f0    	mov    %ax,0xf03312c8
f0104339:	66 c7 05 ca 12 33 f0 	movw   $0x8,0xf03312ca
f0104340:	08 00 
f0104342:	c6 05 cc 12 33 f0 00 	movb   $0x0,0xf03312cc
f0104349:	c6 05 cd 12 33 f0 8e 	movb   $0x8e,0xf03312cd
f0104350:	c1 e8 10             	shr    $0x10,%eax
f0104353:	66 a3 ce 12 33 f0    	mov    %ax,0xf03312ce
        SETGATE(idt[14], 0, GD_KT, th14, 0);
f0104359:	b8 1c 4d 10 f0       	mov    $0xf0104d1c,%eax
f010435e:	66 a3 d0 12 33 f0    	mov    %ax,0xf03312d0
f0104364:	66 c7 05 d2 12 33 f0 	movw   $0x8,0xf03312d2
f010436b:	08 00 
f010436d:	c6 05 d4 12 33 f0 00 	movb   $0x0,0xf03312d4
f0104374:	c6 05 d5 12 33 f0 8e 	movb   $0x8e,0xf03312d5
f010437b:	c1 e8 10             	shr    $0x10,%eax
f010437e:	66 a3 d6 12 33 f0    	mov    %ax,0xf03312d6
        SETGATE(idt[16], 0, GD_KT, th16, 0);
f0104384:	b8 20 4d 10 f0       	mov    $0xf0104d20,%eax
f0104389:	66 a3 e0 12 33 f0    	mov    %ax,0xf03312e0
f010438f:	66 c7 05 e2 12 33 f0 	movw   $0x8,0xf03312e2
f0104396:	08 00 
f0104398:	c6 05 e4 12 33 f0 00 	movb   $0x0,0xf03312e4
f010439f:	c6 05 e5 12 33 f0 8e 	movb   $0x8e,0xf03312e5
f01043a6:	c1 e8 10             	shr    $0x10,%eax
f01043a9:	66 a3 e6 12 33 f0    	mov    %ax,0xf03312e6
        SETGATE(idt[48], 0, GD_KT, th48, 3); //syscall
f01043af:	b8 26 4d 10 f0       	mov    $0xf0104d26,%eax
f01043b4:	66 a3 e0 13 33 f0    	mov    %ax,0xf03313e0
f01043ba:	66 c7 05 e2 13 33 f0 	movw   $0x8,0xf03313e2
f01043c1:	08 00 
f01043c3:	c6 05 e4 13 33 f0 00 	movb   $0x0,0xf03313e4
f01043ca:	c6 05 e5 13 33 f0 ee 	movb   $0xee,0xf03313e5
f01043d1:	c1 e8 10             	shr    $0x10,%eax
f01043d4:	66 a3 e6 13 33 f0    	mov    %ax,0xf03313e6

        SETGATE(idt[IRQ_OFFSET + 0], 0, GD_KT, irq0, 0);
f01043da:	b8 2c 4d 10 f0       	mov    $0xf0104d2c,%eax
f01043df:	66 a3 60 13 33 f0    	mov    %ax,0xf0331360
f01043e5:	66 c7 05 62 13 33 f0 	movw   $0x8,0xf0331362
f01043ec:	08 00 
f01043ee:	c6 05 64 13 33 f0 00 	movb   $0x0,0xf0331364
f01043f5:	c6 05 65 13 33 f0 8e 	movb   $0x8e,0xf0331365
f01043fc:	c1 e8 10             	shr    $0x10,%eax
f01043ff:	66 a3 66 13 33 f0    	mov    %ax,0xf0331366
        SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, irq1, 0);
f0104405:	b8 32 4d 10 f0       	mov    $0xf0104d32,%eax
f010440a:	66 a3 68 13 33 f0    	mov    %ax,0xf0331368
f0104410:	66 c7 05 6a 13 33 f0 	movw   $0x8,0xf033136a
f0104417:	08 00 
f0104419:	c6 05 6c 13 33 f0 00 	movb   $0x0,0xf033136c
f0104420:	c6 05 6d 13 33 f0 8e 	movb   $0x8e,0xf033136d
f0104427:	c1 e8 10             	shr    $0x10,%eax
f010442a:	66 a3 6e 13 33 f0    	mov    %ax,0xf033136e
        SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, irq2, 0);
f0104430:	b8 38 4d 10 f0       	mov    $0xf0104d38,%eax
f0104435:	66 a3 70 13 33 f0    	mov    %ax,0xf0331370
f010443b:	66 c7 05 72 13 33 f0 	movw   $0x8,0xf0331372
f0104442:	08 00 
f0104444:	c6 05 74 13 33 f0 00 	movb   $0x0,0xf0331374
f010444b:	c6 05 75 13 33 f0 8e 	movb   $0x8e,0xf0331375
f0104452:	c1 e8 10             	shr    $0x10,%eax
f0104455:	66 a3 76 13 33 f0    	mov    %ax,0xf0331376
        SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, irq3, 0);
f010445b:	b8 3e 4d 10 f0       	mov    $0xf0104d3e,%eax
f0104460:	66 a3 78 13 33 f0    	mov    %ax,0xf0331378
f0104466:	66 c7 05 7a 13 33 f0 	movw   $0x8,0xf033137a
f010446d:	08 00 
f010446f:	c6 05 7c 13 33 f0 00 	movb   $0x0,0xf033137c
f0104476:	c6 05 7d 13 33 f0 8e 	movb   $0x8e,0xf033137d
f010447d:	c1 e8 10             	shr    $0x10,%eax
f0104480:	66 a3 7e 13 33 f0    	mov    %ax,0xf033137e
        SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, irq4, 0);
f0104486:	b8 44 4d 10 f0       	mov    $0xf0104d44,%eax
f010448b:	66 a3 80 13 33 f0    	mov    %ax,0xf0331380
f0104491:	66 c7 05 82 13 33 f0 	movw   $0x8,0xf0331382
f0104498:	08 00 
f010449a:	c6 05 84 13 33 f0 00 	movb   $0x0,0xf0331384
f01044a1:	c6 05 85 13 33 f0 8e 	movb   $0x8e,0xf0331385
f01044a8:	c1 e8 10             	shr    $0x10,%eax
f01044ab:	66 a3 86 13 33 f0    	mov    %ax,0xf0331386
        SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, irq5, 0);
f01044b1:	b8 4a 4d 10 f0       	mov    $0xf0104d4a,%eax
f01044b6:	66 a3 88 13 33 f0    	mov    %ax,0xf0331388
f01044bc:	66 c7 05 8a 13 33 f0 	movw   $0x8,0xf033138a
f01044c3:	08 00 
f01044c5:	c6 05 8c 13 33 f0 00 	movb   $0x0,0xf033138c
f01044cc:	c6 05 8d 13 33 f0 8e 	movb   $0x8e,0xf033138d
f01044d3:	c1 e8 10             	shr    $0x10,%eax
f01044d6:	66 a3 8e 13 33 f0    	mov    %ax,0xf033138e
        SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, irq6, 0);
f01044dc:	b8 50 4d 10 f0       	mov    $0xf0104d50,%eax
f01044e1:	66 a3 90 13 33 f0    	mov    %ax,0xf0331390
f01044e7:	66 c7 05 92 13 33 f0 	movw   $0x8,0xf0331392
f01044ee:	08 00 
f01044f0:	c6 05 94 13 33 f0 00 	movb   $0x0,0xf0331394
f01044f7:	c6 05 95 13 33 f0 8e 	movb   $0x8e,0xf0331395
f01044fe:	c1 e8 10             	shr    $0x10,%eax
f0104501:	66 a3 96 13 33 f0    	mov    %ax,0xf0331396
        SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, irq7, 0);
f0104507:	b8 56 4d 10 f0       	mov    $0xf0104d56,%eax
f010450c:	66 a3 98 13 33 f0    	mov    %ax,0xf0331398
f0104512:	66 c7 05 9a 13 33 f0 	movw   $0x8,0xf033139a
f0104519:	08 00 
f010451b:	c6 05 9c 13 33 f0 00 	movb   $0x0,0xf033139c
f0104522:	c6 05 9d 13 33 f0 8e 	movb   $0x8e,0xf033139d
f0104529:	c1 e8 10             	shr    $0x10,%eax
f010452c:	66 a3 9e 13 33 f0    	mov    %ax,0xf033139e
        SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, irq8, 0);
f0104532:	b8 5c 4d 10 f0       	mov    $0xf0104d5c,%eax
f0104537:	66 a3 a0 13 33 f0    	mov    %ax,0xf03313a0
f010453d:	66 c7 05 a2 13 33 f0 	movw   $0x8,0xf03313a2
f0104544:	08 00 
f0104546:	c6 05 a4 13 33 f0 00 	movb   $0x0,0xf03313a4
f010454d:	c6 05 a5 13 33 f0 8e 	movb   $0x8e,0xf03313a5
f0104554:	c1 e8 10             	shr    $0x10,%eax
f0104557:	66 a3 a6 13 33 f0    	mov    %ax,0xf03313a6
        SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, irq9, 0);
f010455d:	b8 62 4d 10 f0       	mov    $0xf0104d62,%eax
f0104562:	66 a3 a8 13 33 f0    	mov    %ax,0xf03313a8
f0104568:	66 c7 05 aa 13 33 f0 	movw   $0x8,0xf03313aa
f010456f:	08 00 
f0104571:	c6 05 ac 13 33 f0 00 	movb   $0x0,0xf03313ac
f0104578:	c6 05 ad 13 33 f0 8e 	movb   $0x8e,0xf03313ad
f010457f:	c1 e8 10             	shr    $0x10,%eax
f0104582:	66 a3 ae 13 33 f0    	mov    %ax,0xf03313ae
        SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, irq10, 0);
f0104588:	b8 68 4d 10 f0       	mov    $0xf0104d68,%eax
f010458d:	66 a3 b0 13 33 f0    	mov    %ax,0xf03313b0
f0104593:	66 c7 05 b2 13 33 f0 	movw   $0x8,0xf03313b2
f010459a:	08 00 
f010459c:	c6 05 b4 13 33 f0 00 	movb   $0x0,0xf03313b4
f01045a3:	c6 05 b5 13 33 f0 8e 	movb   $0x8e,0xf03313b5
f01045aa:	c1 e8 10             	shr    $0x10,%eax
f01045ad:	66 a3 b6 13 33 f0    	mov    %ax,0xf03313b6
        SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, irq11, 0);
f01045b3:	b8 6e 4d 10 f0       	mov    $0xf0104d6e,%eax
f01045b8:	66 a3 b8 13 33 f0    	mov    %ax,0xf03313b8
f01045be:	66 c7 05 ba 13 33 f0 	movw   $0x8,0xf03313ba
f01045c5:	08 00 
f01045c7:	c6 05 bc 13 33 f0 00 	movb   $0x0,0xf03313bc
f01045ce:	c6 05 bd 13 33 f0 8e 	movb   $0x8e,0xf03313bd
f01045d5:	c1 e8 10             	shr    $0x10,%eax
f01045d8:	66 a3 be 13 33 f0    	mov    %ax,0xf03313be
        SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, irq12, 0);
f01045de:	b8 74 4d 10 f0       	mov    $0xf0104d74,%eax
f01045e3:	66 a3 c0 13 33 f0    	mov    %ax,0xf03313c0
f01045e9:	66 c7 05 c2 13 33 f0 	movw   $0x8,0xf03313c2
f01045f0:	08 00 
f01045f2:	c6 05 c4 13 33 f0 00 	movb   $0x0,0xf03313c4
f01045f9:	c6 05 c5 13 33 f0 8e 	movb   $0x8e,0xf03313c5
f0104600:	c1 e8 10             	shr    $0x10,%eax
f0104603:	66 a3 c6 13 33 f0    	mov    %ax,0xf03313c6
        SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, irq13, 0);
f0104609:	b8 7a 4d 10 f0       	mov    $0xf0104d7a,%eax
f010460e:	66 a3 c8 13 33 f0    	mov    %ax,0xf03313c8
f0104614:	66 c7 05 ca 13 33 f0 	movw   $0x8,0xf03313ca
f010461b:	08 00 
f010461d:	c6 05 cc 13 33 f0 00 	movb   $0x0,0xf03313cc
f0104624:	c6 05 cd 13 33 f0 8e 	movb   $0x8e,0xf03313cd
f010462b:	c1 e8 10             	shr    $0x10,%eax
f010462e:	66 a3 ce 13 33 f0    	mov    %ax,0xf03313ce
        SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, irq14, 0);
f0104634:	b8 80 4d 10 f0       	mov    $0xf0104d80,%eax
f0104639:	66 a3 d0 13 33 f0    	mov    %ax,0xf03313d0
f010463f:	66 c7 05 d2 13 33 f0 	movw   $0x8,0xf03313d2
f0104646:	08 00 
f0104648:	c6 05 d4 13 33 f0 00 	movb   $0x0,0xf03313d4
f010464f:	c6 05 d5 13 33 f0 8e 	movb   $0x8e,0xf03313d5
f0104656:	c1 e8 10             	shr    $0x10,%eax
f0104659:	66 a3 d6 13 33 f0    	mov    %ax,0xf03313d6
        SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, irq15, 0);
f010465f:	b8 86 4d 10 f0       	mov    $0xf0104d86,%eax
f0104664:	66 a3 d8 13 33 f0    	mov    %ax,0xf03313d8
f010466a:	66 c7 05 da 13 33 f0 	movw   $0x8,0xf03313da
f0104671:	08 00 
f0104673:	c6 05 dc 13 33 f0 00 	movb   $0x0,0xf03313dc
f010467a:	c6 05 dd 13 33 f0 8e 	movb   $0x8e,0xf03313dd
f0104681:	c1 e8 10             	shr    $0x10,%eax
f0104684:	66 a3 de 13 33 f0    	mov    %ax,0xf03313de
            if(i!=2 && i!= 15)
                SETGATE(idt[i], 0, GD_KT, funcs[i], 0);
        }*/

	// Per-CPU setup 
	trap_init_percpu();
f010468a:	e8 a1 f9 ff ff       	call   f0104030 <trap_init_percpu>
}
f010468f:	c9                   	leave  
f0104690:	c3                   	ret    

f0104691 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104691:	55                   	push   %ebp
f0104692:	89 e5                	mov    %esp,%ebp
f0104694:	53                   	push   %ebx
f0104695:	83 ec 14             	sub    $0x14,%esp
f0104698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010469b:	8b 03                	mov    (%ebx),%eax
f010469d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a1:	c7 04 24 f9 80 10 f0 	movl   $0xf01080f9,(%esp)
f01046a8:	e8 69 f9 ff ff       	call   f0104016 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01046ad:	8b 43 04             	mov    0x4(%ebx),%eax
f01046b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b4:	c7 04 24 08 81 10 f0 	movl   $0xf0108108,(%esp)
f01046bb:	e8 56 f9 ff ff       	call   f0104016 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01046c0:	8b 43 08             	mov    0x8(%ebx),%eax
f01046c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c7:	c7 04 24 17 81 10 f0 	movl   $0xf0108117,(%esp)
f01046ce:	e8 43 f9 ff ff       	call   f0104016 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01046d3:	8b 43 0c             	mov    0xc(%ebx),%eax
f01046d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046da:	c7 04 24 26 81 10 f0 	movl   $0xf0108126,(%esp)
f01046e1:	e8 30 f9 ff ff       	call   f0104016 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01046e6:	8b 43 10             	mov    0x10(%ebx),%eax
f01046e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046ed:	c7 04 24 35 81 10 f0 	movl   $0xf0108135,(%esp)
f01046f4:	e8 1d f9 ff ff       	call   f0104016 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01046f9:	8b 43 14             	mov    0x14(%ebx),%eax
f01046fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104700:	c7 04 24 44 81 10 f0 	movl   $0xf0108144,(%esp)
f0104707:	e8 0a f9 ff ff       	call   f0104016 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010470c:	8b 43 18             	mov    0x18(%ebx),%eax
f010470f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104713:	c7 04 24 53 81 10 f0 	movl   $0xf0108153,(%esp)
f010471a:	e8 f7 f8 ff ff       	call   f0104016 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010471f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104722:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104726:	c7 04 24 62 81 10 f0 	movl   $0xf0108162,(%esp)
f010472d:	e8 e4 f8 ff ff       	call   f0104016 <cprintf>
}
f0104732:	83 c4 14             	add    $0x14,%esp
f0104735:	5b                   	pop    %ebx
f0104736:	5d                   	pop    %ebp
f0104737:	c3                   	ret    

f0104738 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104738:	55                   	push   %ebp
f0104739:	89 e5                	mov    %esp,%ebp
f010473b:	53                   	push   %ebx
f010473c:	83 ec 14             	sub    $0x14,%esp
f010473f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104742:	e8 45 20 00 00       	call   f010678c <cpunum>
f0104747:	89 44 24 08          	mov    %eax,0x8(%esp)
f010474b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010474f:	c7 04 24 c6 81 10 f0 	movl   $0xf01081c6,(%esp)
f0104756:	e8 bb f8 ff ff       	call   f0104016 <cprintf>
	print_regs(&tf->tf_regs);
f010475b:	89 1c 24             	mov    %ebx,(%esp)
f010475e:	e8 2e ff ff ff       	call   f0104691 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104763:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104767:	89 44 24 04          	mov    %eax,0x4(%esp)
f010476b:	c7 04 24 e4 81 10 f0 	movl   $0xf01081e4,(%esp)
f0104772:	e8 9f f8 ff ff       	call   f0104016 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104777:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010477b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010477f:	c7 04 24 f7 81 10 f0 	movl   $0xf01081f7,(%esp)
f0104786:	e8 8b f8 ff ff       	call   f0104016 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010478b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010478e:	83 f8 13             	cmp    $0x13,%eax
f0104791:	77 09                	ja     f010479c <print_trapframe+0x64>
		return excnames[trapno];
f0104793:	8b 14 85 80 84 10 f0 	mov    -0xfef7b80(,%eax,4),%edx
f010479a:	eb 20                	jmp    f01047bc <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010479c:	83 f8 30             	cmp    $0x30,%eax
f010479f:	74 0f                	je     f01047b0 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01047a1:	8d 50 e0             	lea    -0x20(%eax),%edx
f01047a4:	83 fa 0f             	cmp    $0xf,%edx
f01047a7:	77 0e                	ja     f01047b7 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01047a9:	ba 7d 81 10 f0       	mov    $0xf010817d,%edx
f01047ae:	eb 0c                	jmp    f01047bc <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01047b0:	ba 71 81 10 f0       	mov    $0xf0108171,%edx
f01047b5:	eb 05                	jmp    f01047bc <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01047b7:	ba 90 81 10 f0       	mov    $0xf0108190,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01047bc:	89 54 24 08          	mov    %edx,0x8(%esp)
f01047c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047c4:	c7 04 24 0a 82 10 f0 	movl   $0xf010820a,(%esp)
f01047cb:	e8 46 f8 ff ff       	call   f0104016 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01047d0:	3b 1d 60 1a 33 f0    	cmp    0xf0331a60,%ebx
f01047d6:	75 19                	jne    f01047f1 <print_trapframe+0xb9>
f01047d8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01047dc:	75 13                	jne    f01047f1 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01047de:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01047e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047e5:	c7 04 24 1c 82 10 f0 	movl   $0xf010821c,(%esp)
f01047ec:	e8 25 f8 ff ff       	call   f0104016 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01047f1:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01047f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047f8:	c7 04 24 2b 82 10 f0 	movl   $0xf010822b,(%esp)
f01047ff:	e8 12 f8 ff ff       	call   f0104016 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104804:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104808:	75 4d                	jne    f0104857 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010480a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010480d:	a8 01                	test   $0x1,%al
f010480f:	74 07                	je     f0104818 <print_trapframe+0xe0>
f0104811:	b9 9f 81 10 f0       	mov    $0xf010819f,%ecx
f0104816:	eb 05                	jmp    f010481d <print_trapframe+0xe5>
f0104818:	b9 aa 81 10 f0       	mov    $0xf01081aa,%ecx
f010481d:	a8 02                	test   $0x2,%al
f010481f:	74 07                	je     f0104828 <print_trapframe+0xf0>
f0104821:	ba b6 81 10 f0       	mov    $0xf01081b6,%edx
f0104826:	eb 05                	jmp    f010482d <print_trapframe+0xf5>
f0104828:	ba bc 81 10 f0       	mov    $0xf01081bc,%edx
f010482d:	a8 04                	test   $0x4,%al
f010482f:	74 07                	je     f0104838 <print_trapframe+0x100>
f0104831:	b8 c1 81 10 f0       	mov    $0xf01081c1,%eax
f0104836:	eb 05                	jmp    f010483d <print_trapframe+0x105>
f0104838:	b8 08 83 10 f0       	mov    $0xf0108308,%eax
f010483d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104841:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104845:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104849:	c7 04 24 39 82 10 f0 	movl   $0xf0108239,(%esp)
f0104850:	e8 c1 f7 ff ff       	call   f0104016 <cprintf>
f0104855:	eb 0c                	jmp    f0104863 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104857:	c7 04 24 f6 7f 10 f0 	movl   $0xf0107ff6,(%esp)
f010485e:	e8 b3 f7 ff ff       	call   f0104016 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104863:	8b 43 30             	mov    0x30(%ebx),%eax
f0104866:	89 44 24 04          	mov    %eax,0x4(%esp)
f010486a:	c7 04 24 48 82 10 f0 	movl   $0xf0108248,(%esp)
f0104871:	e8 a0 f7 ff ff       	call   f0104016 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104876:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010487a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010487e:	c7 04 24 57 82 10 f0 	movl   $0xf0108257,(%esp)
f0104885:	e8 8c f7 ff ff       	call   f0104016 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010488a:	8b 43 38             	mov    0x38(%ebx),%eax
f010488d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104891:	c7 04 24 6a 82 10 f0 	movl   $0xf010826a,(%esp)
f0104898:	e8 79 f7 ff ff       	call   f0104016 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010489d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01048a1:	74 27                	je     f01048ca <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01048a3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01048a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048aa:	c7 04 24 79 82 10 f0 	movl   $0xf0108279,(%esp)
f01048b1:	e8 60 f7 ff ff       	call   f0104016 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01048b6:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01048ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048be:	c7 04 24 88 82 10 f0 	movl   $0xf0108288,(%esp)
f01048c5:	e8 4c f7 ff ff       	call   f0104016 <cprintf>
	}
}
f01048ca:	83 c4 14             	add    $0x14,%esp
f01048cd:	5b                   	pop    %ebx
f01048ce:	5d                   	pop    %ebp
f01048cf:	c3                   	ret    

f01048d0 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01048d0:	55                   	push   %ebp
f01048d1:	89 e5                	mov    %esp,%ebp
f01048d3:	57                   	push   %edi
f01048d4:	56                   	push   %esi
f01048d5:	53                   	push   %ebx
f01048d6:	83 ec 2c             	sub    $0x2c,%esp
f01048d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01048dc:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
        
        if((tf->tf_cs&3) == 0){
f01048df:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01048e3:	75 1c                	jne    f0104901 <page_fault_handler+0x31>
            panic("page_fault fail!\n");
f01048e5:	c7 44 24 08 9b 82 10 	movl   $0xf010829b,0x8(%esp)
f01048ec:	f0 
f01048ed:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f01048f4:	00 
f01048f5:	c7 04 24 ad 82 10 f0 	movl   $0xf01082ad,(%esp)
f01048fc:	e8 3f b7 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        
        if(curenv->env_pgfault_upcall != NULL){
f0104901:	e8 86 1e 00 00       	call   f010678c <cpunum>
f0104906:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010490d:	29 c2                	sub    %eax,%edx
f010490f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104912:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104919:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010491d:	0f 84 f0 00 00 00    	je     f0104a13 <page_fault_handler+0x143>
            struct UTrapframe *utf;
            
            if(tf->tf_esp < UXSTACKTOP && tf->tf_esp>=UXSTACKTOP-PGSIZE)
f0104923:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104926:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
            else
                utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f010492c:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
	// LAB 4: Your code here.
        
        if(curenv->env_pgfault_upcall != NULL){
            struct UTrapframe *utf;
            
            if(tf->tf_esp < UXSTACKTOP && tf->tf_esp>=UXSTACKTOP-PGSIZE)
f0104933:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104939:	77 06                	ja     f0104941 <page_fault_handler+0x71>
                utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010493b:	83 e8 38             	sub    $0x38,%eax
f010493e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            else
                utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
            user_mem_assert(curenv,(void *)utf, sizeof(struct UTrapframe), PTE_W); //检查是否可写
f0104941:	e8 46 1e 00 00       	call   f010678c <cpunum>
f0104946:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010494d:	00 
f010494e:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104955:	00 
f0104956:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104959:	89 54 24 04          	mov    %edx,0x4(%esp)
f010495d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104960:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104966:	89 04 24             	mov    %eax,(%esp)
f0104969:	e8 db eb ff ff       	call   f0103549 <user_mem_assert>

            utf->utf_fault_va = fault_va;
f010496e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104971:	89 30                	mov    %esi,(%eax)
            utf->utf_err = tf->tf_err;
f0104973:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104976:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104979:	89 42 04             	mov    %eax,0x4(%edx)
            utf->utf_regs = tf->tf_regs;
f010497c:	89 d7                	mov    %edx,%edi
f010497e:	83 c7 08             	add    $0x8,%edi
f0104981:	89 de                	mov    %ebx,%esi
f0104983:	b8 20 00 00 00       	mov    $0x20,%eax
f0104988:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010498e:	74 03                	je     f0104993 <page_fault_handler+0xc3>
f0104990:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104991:	b0 1f                	mov    $0x1f,%al
f0104993:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104999:	74 05                	je     f01049a0 <page_fault_handler+0xd0>
f010499b:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010499d:	83 e8 02             	sub    $0x2,%eax
f01049a0:	89 c1                	mov    %eax,%ecx
f01049a2:	c1 e9 02             	shr    $0x2,%ecx
f01049a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01049a7:	a8 02                	test   $0x2,%al
f01049a9:	74 02                	je     f01049ad <page_fault_handler+0xdd>
f01049ab:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01049ad:	a8 01                	test   $0x1,%al
f01049af:	74 01                	je     f01049b2 <page_fault_handler+0xe2>
f01049b1:	a4                   	movsb  %ds:(%esi),%es:(%edi)
            utf->utf_eip = tf->tf_eip;
f01049b2:	8b 43 30             	mov    0x30(%ebx),%eax
f01049b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049b8:	89 42 28             	mov    %eax,0x28(%edx)
            utf->utf_eflags = tf->tf_eflags;
f01049bb:	8b 43 38             	mov    0x38(%ebx),%eax
f01049be:	89 42 2c             	mov    %eax,0x2c(%edx)
            utf->utf_esp = tf->tf_esp;
f01049c1:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01049c4:	89 42 30             	mov    %eax,0x30(%edx)

            curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01049c7:	e8 c0 1d 00 00       	call   f010678c <cpunum>
f01049cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cf:	8b 98 28 20 33 f0    	mov    -0xfccdfd8(%eax),%ebx
f01049d5:	e8 b2 1d 00 00       	call   f010678c <cpunum>
f01049da:	6b c0 74             	imul   $0x74,%eax,%eax
f01049dd:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01049e3:	8b 40 64             	mov    0x64(%eax),%eax
f01049e6:	89 43 30             	mov    %eax,0x30(%ebx)
            curenv->env_tf.tf_esp = (uintptr_t)utf;
f01049e9:	e8 9e 1d 00 00       	call   f010678c <cpunum>
f01049ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f1:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01049f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049fa:	89 50 3c             	mov    %edx,0x3c(%eax)
            env_run(curenv);
f01049fd:	e8 8a 1d 00 00       	call   f010678c <cpunum>
f0104a02:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a05:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104a0b:	89 04 24             	mov    %eax,(%esp)
f0104a0e:	e8 85 f3 ff ff       	call   f0103d98 <env_run>
        }
        
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104a13:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104a16:	e8 71 1d 00 00       	call   f010678c <cpunum>
            curenv->env_tf.tf_esp = (uintptr_t)utf;
            env_run(curenv);
        }
        
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104a1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104a1f:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104a23:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a2a:	29 c2                	sub    %eax,%edx
f0104a2c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a2f:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
            curenv->env_tf.tf_esp = (uintptr_t)utf;
            env_run(curenv);
        }
        
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104a36:	8b 40 48             	mov    0x48(%eax),%eax
f0104a39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a3d:	c7 04 24 54 84 10 f0 	movl   $0xf0108454,(%esp)
f0104a44:	e8 cd f5 ff ff       	call   f0104016 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104a49:	89 1c 24             	mov    %ebx,(%esp)
f0104a4c:	e8 e7 fc ff ff       	call   f0104738 <print_trapframe>
	env_destroy(curenv);
f0104a51:	e8 36 1d 00 00       	call   f010678c <cpunum>
f0104a56:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a5d:	29 c2                	sub    %eax,%edx
f0104a5f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a62:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104a69:	89 04 24             	mov    %eax,(%esp)
f0104a6c:	e8 68 f2 ff ff       	call   f0103cd9 <env_destroy>
}
f0104a71:	83 c4 2c             	add    $0x2c,%esp
f0104a74:	5b                   	pop    %ebx
f0104a75:	5e                   	pop    %esi
f0104a76:	5f                   	pop    %edi
f0104a77:	5d                   	pop    %ebp
f0104a78:	c3                   	ret    

f0104a79 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104a79:	55                   	push   %ebp
f0104a7a:	89 e5                	mov    %esp,%ebp
f0104a7c:	57                   	push   %edi
f0104a7d:	56                   	push   %esi
f0104a7e:	83 ec 20             	sub    $0x20,%esp
f0104a81:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104a84:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104a85:	83 3d 80 1e 33 f0 00 	cmpl   $0x0,0xf0331e80
f0104a8c:	74 01                	je     f0104a8f <trap+0x16>
		asm volatile("hlt");
f0104a8e:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104a8f:	e8 f8 1c 00 00       	call   f010678c <cpunum>
f0104a94:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a9b:	29 c2                	sub    %eax,%edx
f0104a9d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104aa0:	8d 14 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104aa7:	b8 01 00 00 00       	mov    $0x1,%eax
f0104aac:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104ab0:	83 f8 02             	cmp    $0x2,%eax
f0104ab3:	75 0c                	jne    f0104ac1 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104ab5:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104abc:	e8 8a 1f 00 00       	call   f0106a4b <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104ac1:	9c                   	pushf  
f0104ac2:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104ac3:	f6 c4 02             	test   $0x2,%ah
f0104ac6:	74 24                	je     f0104aec <trap+0x73>
f0104ac8:	c7 44 24 0c b9 82 10 	movl   $0xf01082b9,0xc(%esp)
f0104acf:	f0 
f0104ad0:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0104ad7:	f0 
f0104ad8:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f0104adf:	00 
f0104ae0:	c7 04 24 ad 82 10 f0 	movl   $0xf01082ad,(%esp)
f0104ae7:	e8 54 b5 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104aec:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104af0:	83 e0 03             	and    $0x3,%eax
f0104af3:	83 f8 03             	cmp    $0x3,%eax
f0104af6:	0f 85 a7 00 00 00    	jne    f0104ba3 <trap+0x12a>
f0104afc:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104b03:	e8 43 1f 00 00       	call   f0106a4b <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
                lock_kernel();
		assert(curenv);
f0104b08:	e8 7f 1c 00 00       	call   f010678c <cpunum>
f0104b0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b10:	83 b8 28 20 33 f0 00 	cmpl   $0x0,-0xfccdfd8(%eax)
f0104b17:	75 24                	jne    f0104b3d <trap+0xc4>
f0104b19:	c7 44 24 0c d2 82 10 	movl   $0xf01082d2,0xc(%esp)
f0104b20:	f0 
f0104b21:	c7 44 24 08 27 7d 10 	movl   $0xf0107d27,0x8(%esp)
f0104b28:	f0 
f0104b29:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0104b30:	00 
f0104b31:	c7 04 24 ad 82 10 f0 	movl   $0xf01082ad,(%esp)
f0104b38:	e8 03 b5 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104b3d:	e8 4a 1c 00 00       	call   f010678c <cpunum>
f0104b42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b45:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104b4b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104b4f:	75 2d                	jne    f0104b7e <trap+0x105>
			env_free(curenv);
f0104b51:	e8 36 1c 00 00       	call   f010678c <cpunum>
f0104b56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b59:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104b5f:	89 04 24             	mov    %eax,(%esp)
f0104b62:	e8 4e ef ff ff       	call   f0103ab5 <env_free>
			curenv = NULL;
f0104b67:	e8 20 1c 00 00       	call   f010678c <cpunum>
f0104b6c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6f:	c7 80 28 20 33 f0 00 	movl   $0x0,-0xfccdfd8(%eax)
f0104b76:	00 00 00 
			sched_yield();
f0104b79:	e8 10 03 00 00       	call   f0104e8e <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104b7e:	e8 09 1c 00 00       	call   f010678c <cpunum>
f0104b83:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b86:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104b8c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b91:	89 c7                	mov    %eax,%edi
f0104b93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104b95:	e8 f2 1b 00 00       	call   f010678c <cpunum>
f0104b9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9d:	8b b0 28 20 33 f0    	mov    -0xfccdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104ba3:	89 35 60 1a 33 f0    	mov    %esi,0xf0331a60
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104ba9:	8b 46 28             	mov    0x28(%esi),%eax
f0104bac:	83 f8 27             	cmp    $0x27,%eax
f0104baf:	75 19                	jne    f0104bca <trap+0x151>
		cprintf("Spurious interrupt on irq 7\n");
f0104bb1:	c7 04 24 d9 82 10 f0 	movl   $0xf01082d9,(%esp)
f0104bb8:	e8 59 f4 ff ff       	call   f0104016 <cprintf>
		print_trapframe(tf);
f0104bbd:	89 34 24             	mov    %esi,(%esp)
f0104bc0:	e8 73 fb ff ff       	call   f0104738 <print_trapframe>
f0104bc5:	e9 a8 00 00 00       	jmp    f0104c72 <trap+0x1f9>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
        
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104bca:	83 f8 20             	cmp    $0x20,%eax
f0104bcd:	75 0a                	jne    f0104bd9 <trap+0x160>
            lapic_eoi();
f0104bcf:	e8 0f 1d 00 00       	call   f01068e3 <lapic_eoi>
            sched_yield();
f0104bd4:	e8 b5 02 00 00       	call   f0104e8e <sched_yield>
        

//=======
        //cprintf("trap_dispath：%d\n",tf->tf_trapno); 
        //cprintf("T_BRKPT:%d\n",T_BRKPT);
        if(tf->tf_trapno == T_PGFLT){
f0104bd9:	83 f8 0e             	cmp    $0xe,%eax
f0104bdc:	75 0d                	jne    f0104beb <trap+0x172>
            page_fault_handler(tf);
f0104bde:	89 34 24             	mov    %esi,(%esp)
f0104be1:	e8 ea fc ff ff       	call   f01048d0 <page_fault_handler>
f0104be6:	e9 87 00 00 00       	jmp    f0104c72 <trap+0x1f9>
            return ;
        }      
        if(tf->tf_trapno == T_BRKPT){
f0104beb:	83 f8 03             	cmp    $0x3,%eax
f0104bee:	75 0a                	jne    f0104bfa <trap+0x181>
            //cprintf("test for brkpt\n");
            monitor(tf);
f0104bf0:	89 34 24             	mov    %esi,(%esp)
f0104bf3:	e8 77 bd ff ff       	call   f010096f <monitor>
f0104bf8:	eb 78                	jmp    f0104c72 <trap+0x1f9>
            return ;
        }
        if(tf->tf_trapno == T_SYSCALL){
f0104bfa:	83 f8 30             	cmp    $0x30,%eax
f0104bfd:	75 32                	jne    f0104c31 <trap+0x1b8>
            if((tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0104bff:	8b 46 04             	mov    0x4(%esi),%eax
f0104c02:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104c06:	8b 06                	mov    (%esi),%eax
f0104c08:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104c0c:	8b 46 10             	mov    0x10(%esi),%eax
f0104c0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c13:	8b 46 18             	mov    0x18(%esi),%eax
f0104c16:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c1a:	8b 46 14             	mov    0x14(%esi),%eax
f0104c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c21:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104c24:	89 04 24             	mov    %eax,(%esp)
f0104c27:	e8 fb 02 00 00       	call   f0104f27 <syscall>
f0104c2c:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104c2f:	eb 41                	jmp    f0104c72 <trap+0x1f9>
                panic("trap_dispatch fail at syscall!\n");
            return ;
        }
//>>>>>>> lab3
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104c31:	89 34 24             	mov    %esi,(%esp)
f0104c34:	e8 ff fa ff ff       	call   f0104738 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104c39:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104c3e:	75 1c                	jne    f0104c5c <trap+0x1e3>
		panic("unhandled trap in kernel");
f0104c40:	c7 44 24 08 f6 82 10 	movl   $0xf01082f6,0x8(%esp)
f0104c47:	f0 
f0104c48:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f0104c4f:	00 
f0104c50:	c7 04 24 ad 82 10 f0 	movl   $0xf01082ad,(%esp)
f0104c57:	e8 e4 b3 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104c5c:	e8 2b 1b 00 00       	call   f010678c <cpunum>
f0104c61:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c64:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104c6a:	89 04 24             	mov    %eax,(%esp)
f0104c6d:	e8 67 f0 ff ff       	call   f0103cd9 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104c72:	e8 15 1b 00 00       	call   f010678c <cpunum>
f0104c77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c7a:	83 b8 28 20 33 f0 00 	cmpl   $0x0,-0xfccdfd8(%eax)
f0104c81:	74 2a                	je     f0104cad <trap+0x234>
f0104c83:	e8 04 1b 00 00       	call   f010678c <cpunum>
f0104c88:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c8b:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104c91:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104c95:	75 16                	jne    f0104cad <trap+0x234>
		env_run(curenv);
f0104c97:	e8 f0 1a 00 00       	call   f010678c <cpunum>
f0104c9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c9f:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104ca5:	89 04 24             	mov    %eax,(%esp)
f0104ca8:	e8 eb f0 ff ff       	call   f0103d98 <env_run>
	else
		sched_yield();
f0104cad:	e8 dc 01 00 00       	call   f0104e8e <sched_yield>
	...

f0104cb4 <th0>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
        // trap number can find in inc/trap. h and mit website
        
        TRAPHANDLER_NOEC(th0, 0)
f0104cb4:	6a 00                	push   $0x0
f0104cb6:	6a 00                	push   $0x0
f0104cb8:	e9 cf 00 00 00       	jmp    f0104d8c <_alltraps>
f0104cbd:	90                   	nop

f0104cbe <th1>:
        TRAPHANDLER_NOEC(th1, 1)
f0104cbe:	6a 00                	push   $0x0
f0104cc0:	6a 01                	push   $0x1
f0104cc2:	e9 c5 00 00 00       	jmp    f0104d8c <_alltraps>
f0104cc7:	90                   	nop

f0104cc8 <th3>:
        TRAPHANDLER_NOEC(th3, 3)
f0104cc8:	6a 00                	push   $0x0
f0104cca:	6a 03                	push   $0x3
f0104ccc:	e9 bb 00 00 00       	jmp    f0104d8c <_alltraps>
f0104cd1:	90                   	nop

f0104cd2 <th4>:
        TRAPHANDLER_NOEC(th4, 4)
f0104cd2:	6a 00                	push   $0x0
f0104cd4:	6a 04                	push   $0x4
f0104cd6:	e9 b1 00 00 00       	jmp    f0104d8c <_alltraps>
f0104cdb:	90                   	nop

f0104cdc <th5>:
        TRAPHANDLER_NOEC(th5, 5)
f0104cdc:	6a 00                	push   $0x0
f0104cde:	6a 05                	push   $0x5
f0104ce0:	e9 a7 00 00 00       	jmp    f0104d8c <_alltraps>
f0104ce5:	90                   	nop

f0104ce6 <th6>:
        TRAPHANDLER_NOEC(th6, 6)
f0104ce6:	6a 00                	push   $0x0
f0104ce8:	6a 06                	push   $0x6
f0104cea:	e9 9d 00 00 00       	jmp    f0104d8c <_alltraps>
f0104cef:	90                   	nop

f0104cf0 <th7>:
        TRAPHANDLER_NOEC(th7, 7)
f0104cf0:	6a 00                	push   $0x0
f0104cf2:	6a 07                	push   $0x7
f0104cf4:	e9 93 00 00 00       	jmp    f0104d8c <_alltraps>
f0104cf9:	90                   	nop

f0104cfa <th8>:
        TRAPHANDLER(th8, 8)
f0104cfa:	6a 08                	push   $0x8
f0104cfc:	e9 8b 00 00 00       	jmp    f0104d8c <_alltraps>
f0104d01:	90                   	nop

f0104d02 <th9>:
        TRAPHANDLER_NOEC(th9, 9)
f0104d02:	6a 00                	push   $0x0
f0104d04:	6a 09                	push   $0x9
f0104d06:	e9 81 00 00 00       	jmp    f0104d8c <_alltraps>
f0104d0b:	90                   	nop

f0104d0c <th10>:
        TRAPHANDLER(th10, 10)
f0104d0c:	6a 0a                	push   $0xa
f0104d0e:	eb 7c                	jmp    f0104d8c <_alltraps>

f0104d10 <th11>:
        TRAPHANDLER(th11, 11)
f0104d10:	6a 0b                	push   $0xb
f0104d12:	eb 78                	jmp    f0104d8c <_alltraps>

f0104d14 <th12>:
        TRAPHANDLER(th12, 12)
f0104d14:	6a 0c                	push   $0xc
f0104d16:	eb 74                	jmp    f0104d8c <_alltraps>

f0104d18 <th13>:
        TRAPHANDLER(th13, 13)
f0104d18:	6a 0d                	push   $0xd
f0104d1a:	eb 70                	jmp    f0104d8c <_alltraps>

f0104d1c <th14>:
        TRAPHANDLER(th14, 14)
f0104d1c:	6a 0e                	push   $0xe
f0104d1e:	eb 6c                	jmp    f0104d8c <_alltraps>

f0104d20 <th16>:
        TRAPHANDLER_NOEC(th16,16)
f0104d20:	6a 00                	push   $0x0
f0104d22:	6a 10                	push   $0x10
f0104d24:	eb 66                	jmp    f0104d8c <_alltraps>

f0104d26 <th48>:

        TRAPHANDLER_NOEC(th48,48)   //syscall
f0104d26:	6a 00                	push   $0x0
f0104d28:	6a 30                	push   $0x30
f0104d2a:	eb 60                	jmp    f0104d8c <_alltraps>

f0104d2c <irq0>:

        TRAPHANDLER_NOEC(irq0,IRQ_OFFSET + 0)
f0104d2c:	6a 00                	push   $0x0
f0104d2e:	6a 20                	push   $0x20
f0104d30:	eb 5a                	jmp    f0104d8c <_alltraps>

f0104d32 <irq1>:
        TRAPHANDLER_NOEC(irq1,IRQ_OFFSET + 1)
f0104d32:	6a 00                	push   $0x0
f0104d34:	6a 21                	push   $0x21
f0104d36:	eb 54                	jmp    f0104d8c <_alltraps>

f0104d38 <irq2>:
        TRAPHANDLER_NOEC(irq2,IRQ_OFFSET + 2)
f0104d38:	6a 00                	push   $0x0
f0104d3a:	6a 22                	push   $0x22
f0104d3c:	eb 4e                	jmp    f0104d8c <_alltraps>

f0104d3e <irq3>:
        TRAPHANDLER_NOEC(irq3,IRQ_OFFSET + 3)
f0104d3e:	6a 00                	push   $0x0
f0104d40:	6a 23                	push   $0x23
f0104d42:	eb 48                	jmp    f0104d8c <_alltraps>

f0104d44 <irq4>:
        TRAPHANDLER_NOEC(irq4,IRQ_OFFSET + 4)
f0104d44:	6a 00                	push   $0x0
f0104d46:	6a 24                	push   $0x24
f0104d48:	eb 42                	jmp    f0104d8c <_alltraps>

f0104d4a <irq5>:
        TRAPHANDLER_NOEC(irq5,IRQ_OFFSET + 5)
f0104d4a:	6a 00                	push   $0x0
f0104d4c:	6a 25                	push   $0x25
f0104d4e:	eb 3c                	jmp    f0104d8c <_alltraps>

f0104d50 <irq6>:
        TRAPHANDLER_NOEC(irq6,IRQ_OFFSET + 6)
f0104d50:	6a 00                	push   $0x0
f0104d52:	6a 26                	push   $0x26
f0104d54:	eb 36                	jmp    f0104d8c <_alltraps>

f0104d56 <irq7>:
        TRAPHANDLER_NOEC(irq7,IRQ_OFFSET + 7)
f0104d56:	6a 00                	push   $0x0
f0104d58:	6a 27                	push   $0x27
f0104d5a:	eb 30                	jmp    f0104d8c <_alltraps>

f0104d5c <irq8>:
        TRAPHANDLER_NOEC(irq8,IRQ_OFFSET + 8)
f0104d5c:	6a 00                	push   $0x0
f0104d5e:	6a 28                	push   $0x28
f0104d60:	eb 2a                	jmp    f0104d8c <_alltraps>

f0104d62 <irq9>:
        TRAPHANDLER_NOEC(irq9,IRQ_OFFSET + 9)
f0104d62:	6a 00                	push   $0x0
f0104d64:	6a 29                	push   $0x29
f0104d66:	eb 24                	jmp    f0104d8c <_alltraps>

f0104d68 <irq10>:
        TRAPHANDLER_NOEC(irq10,IRQ_OFFSET + 10)
f0104d68:	6a 00                	push   $0x0
f0104d6a:	6a 2a                	push   $0x2a
f0104d6c:	eb 1e                	jmp    f0104d8c <_alltraps>

f0104d6e <irq11>:
        TRAPHANDLER_NOEC(irq11,IRQ_OFFSET + 11)
f0104d6e:	6a 00                	push   $0x0
f0104d70:	6a 2b                	push   $0x2b
f0104d72:	eb 18                	jmp    f0104d8c <_alltraps>

f0104d74 <irq12>:
        TRAPHANDLER_NOEC(irq12,IRQ_OFFSET + 12)
f0104d74:	6a 00                	push   $0x0
f0104d76:	6a 2c                	push   $0x2c
f0104d78:	eb 12                	jmp    f0104d8c <_alltraps>

f0104d7a <irq13>:
        TRAPHANDLER_NOEC(irq13,IRQ_OFFSET + 13)
f0104d7a:	6a 00                	push   $0x0
f0104d7c:	6a 2d                	push   $0x2d
f0104d7e:	eb 0c                	jmp    f0104d8c <_alltraps>

f0104d80 <irq14>:
        TRAPHANDLER_NOEC(irq14,IRQ_OFFSET + 14)
f0104d80:	6a 00                	push   $0x0
f0104d82:	6a 2e                	push   $0x2e
f0104d84:	eb 06                	jmp    f0104d8c <_alltraps>

f0104d86 <irq15>:
        TRAPHANDLER_NOEC(irq15,IRQ_OFFSET + 15)
f0104d86:	6a 00                	push   $0x0
f0104d88:	6a 2f                	push   $0x2f
f0104d8a:	eb 00                	jmp    f0104d8c <_alltraps>

f0104d8c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
        pushl %ds
f0104d8c:	1e                   	push   %ds
        pushl %es
f0104d8d:	06                   	push   %es
        pushal
f0104d8e:	60                   	pusha  
        pushl $GD_KD
f0104d8f:	6a 10                	push   $0x10
        popl %ds
f0104d91:	1f                   	pop    %ds
        pushl $GD_KD
f0104d92:	6a 10                	push   $0x10
        popl %es
f0104d94:	07                   	pop    %es
        pushl %esp
f0104d95:	54                   	push   %esp
        call trap
f0104d96:	e8 de fc ff ff       	call   f0104a79 <trap>
	...

f0104d9c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104d9c:	55                   	push   %ebp
f0104d9d:	89 e5                	mov    %esp,%ebp
f0104d9f:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104da2:	8b 15 48 12 33 f0    	mov    0xf0331248,%edx
f0104da8:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104dab:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104db0:	8b 0a                	mov    (%edx),%ecx
f0104db2:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104db3:	83 f9 02             	cmp    $0x2,%ecx
f0104db6:	76 0d                	jbe    f0104dc5 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104db8:	40                   	inc    %eax
f0104db9:	83 c2 7c             	add    $0x7c,%edx
f0104dbc:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104dc1:	75 ed                	jne    f0104db0 <sched_halt+0x14>
f0104dc3:	eb 07                	jmp    f0104dcc <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104dc5:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104dca:	75 1a                	jne    f0104de6 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104dcc:	c7 04 24 d0 84 10 f0 	movl   $0xf01084d0,(%esp)
f0104dd3:	e8 3e f2 ff ff       	call   f0104016 <cprintf>
		while (1)
			monitor(NULL);
f0104dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104ddf:	e8 8b bb ff ff       	call   f010096f <monitor>
f0104de4:	eb f2                	jmp    f0104dd8 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104de6:	e8 a1 19 00 00       	call   f010678c <cpunum>
f0104deb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104df2:	29 c2                	sub    %eax,%edx
f0104df4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104df7:	c7 04 85 28 20 33 f0 	movl   $0x0,-0xfccdfd8(,%eax,4)
f0104dfe:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104e02:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104e07:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104e0c:	77 20                	ja     f0104e2e <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104e0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e12:	c7 44 24 08 84 6e 10 	movl   $0xf0106e84,0x8(%esp)
f0104e19:	f0 
f0104e1a:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
f0104e21:	00 
f0104e22:	c7 04 24 f9 84 10 f0 	movl   $0xf01084f9,(%esp)
f0104e29:	e8 12 b2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104e2e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104e33:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104e36:	e8 51 19 00 00       	call   f010678c <cpunum>
f0104e3b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e42:	29 c2                	sub    %eax,%edx
f0104e44:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e47:	8d 14 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104e4e:	b8 02 00 00 00       	mov    $0x2,%eax
f0104e53:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104e57:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104e5e:	e8 8b 1c 00 00       	call   f0106aee <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104e63:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104e65:	e8 22 19 00 00       	call   f010678c <cpunum>
f0104e6a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e71:	29 c2                	sub    %eax,%edx
f0104e73:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104e76:	8b 04 85 30 20 33 f0 	mov    -0xfccdfd0(,%eax,4),%eax
f0104e7d:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104e82:	89 c4                	mov    %eax,%esp
f0104e84:	6a 00                	push   $0x0
f0104e86:	6a 00                	push   $0x0
f0104e88:	fb                   	sti    
f0104e89:	f4                   	hlt    
f0104e8a:	eb fd                	jmp    f0104e89 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104e8c:	c9                   	leave  
f0104e8d:	c3                   	ret    

f0104e8e <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104e8e:	55                   	push   %ebp
f0104e8f:	89 e5                	mov    %esp,%ebp
f0104e91:	57                   	push   %edi
f0104e92:	56                   	push   %esi
f0104e93:	53                   	push   %ebx
f0104e94:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
        uint32_t i,cur_id,idx,flag;
        idle = thiscpu->cpu_env;
f0104e97:	e8 f0 18 00 00       	call   f010678c <cpunum>
f0104e9c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ea3:	29 c2                	sub    %eax,%edx
f0104ea5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ea8:	8b 34 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%esi
        flag = 0;
        if(idle == NULL)
f0104eaf:	85 f6                	test   %esi,%esi
f0104eb1:	74 0b                	je     f0104ebe <sched_yield+0x30>
            cur_id = 0;
        else 
            cur_id = ENVX(idle->env_id);
f0104eb3:	8b 5e 48             	mov    0x48(%esi),%ebx
f0104eb6:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0104ebc:	eb 05                	jmp    f0104ec3 <sched_yield+0x35>
	// LAB 4: Your code here.
        uint32_t i,cur_id,idx,flag;
        idle = thiscpu->cpu_env;
        flag = 0;
        if(idle == NULL)
            cur_id = 0;
f0104ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
        else 
            cur_id = ENVX(idle->env_id);
        for(i = 0 ; i < NENV ; i++){
            idx = (cur_id + i) % NENV;
            if(envs[idx].env_status == ENV_RUNNABLE){
f0104ec3:	8b 0d 48 12 33 f0    	mov    0xf0331248,%ecx
        flag = 0;
        if(idle == NULL)
            cur_id = 0;
        else 
            cur_id = ENVX(idle->env_id);
        for(i = 0 ; i < NENV ; i++){
f0104ec9:	b8 00 00 00 00       	mov    $0x0,%eax
            idx = (cur_id + i) % NENV;
f0104ece:	8d 14 18             	lea    (%eax,%ebx,1),%edx
f0104ed1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
            if(envs[idx].env_status == ENV_RUNNABLE){
f0104ed7:	8d 3c 95 00 00 00 00 	lea    0x0(,%edx,4),%edi
f0104ede:	c1 e2 07             	shl    $0x7,%edx
f0104ee1:	29 fa                	sub    %edi,%edx
f0104ee3:	01 ca                	add    %ecx,%edx
f0104ee5:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104ee9:	75 08                	jne    f0104ef3 <sched_yield+0x65>
                env_run(&envs[idx]);
f0104eeb:	89 14 24             	mov    %edx,(%esp)
f0104eee:	e8 a5 ee ff ff       	call   f0103d98 <env_run>
        flag = 0;
        if(idle == NULL)
            cur_id = 0;
        else 
            cur_id = ENVX(idle->env_id);
        for(i = 0 ; i < NENV ; i++){
f0104ef3:	40                   	inc    %eax
f0104ef4:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ef9:	75 d3                	jne    f0104ece <sched_yield+0x40>
            if(envs[idx].env_status == ENV_RUNNABLE){
                env_run(&envs[idx]);
                flag = 1;
            }    
        }
        if(flag==0 && idle!=NULL && idle->env_status==ENV_RUNNING){
f0104efb:	85 f6                	test   %esi,%esi
f0104efd:	74 0e                	je     f0104f0d <sched_yield+0x7f>
f0104eff:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f0104f03:	75 08                	jne    f0104f0d <sched_yield+0x7f>
            env_run(idle);
f0104f05:	89 34 24             	mov    %esi,(%esp)
f0104f08:	e8 8b ee ff ff       	call   f0103d98 <env_run>
        }
	// sched_halt never returns
	sched_halt();
f0104f0d:	e8 8a fe ff ff       	call   f0104d9c <sched_halt>
}
f0104f12:	83 c4 1c             	add    $0x1c,%esp
f0104f15:	5b                   	pop    %ebx
f0104f16:	5e                   	pop    %esi
f0104f17:	5f                   	pop    %edi
f0104f18:	5d                   	pop    %ebp
f0104f19:	c3                   	ret    
	...

f0104f1c <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104f1c:	55                   	push   %ebp
f0104f1d:	89 e5                	mov    %esp,%ebp
f0104f1f:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104f22:	e8 67 ff ff ff       	call   f0104e8e <sched_yield>

f0104f27 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104f27:	55                   	push   %ebp
f0104f28:	89 e5                	mov    %esp,%ebp
f0104f2a:	57                   	push   %edi
f0104f2b:	56                   	push   %esi
f0104f2c:	53                   	push   %ebx
f0104f2d:	83 ec 3c             	sub    $0x3c,%esp
f0104f30:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f33:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104f36:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f39:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        //case查询 inc/syscall.h
        int32_t ret = 0;
	switch (syscallno) {
f0104f3c:	83 f8 0c             	cmp    $0xc,%eax
f0104f3f:	0f 87 15 06 00 00    	ja     f010555a <syscall+0x633>
f0104f45:	ff 24 85 40 85 10 f0 	jmp    *-0xfef7ac0(,%eax,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
        
        user_mem_assert(curenv, s, len, PTE_U);
f0104f4c:	e8 3b 18 00 00       	call   f010678c <cpunum>
f0104f51:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104f58:	00 
f0104f59:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f5d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f61:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f68:	29 c2                	sub    %eax,%edx
f0104f6a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f6d:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104f74:	89 04 24             	mov    %eax,(%esp)
f0104f77:	e8 cd e5 ff ff       	call   f0103549 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104f7c:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104f80:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104f84:	c7 04 24 06 85 10 f0 	movl   $0xf0108506,(%esp)
f0104f8b:	e8 86 f0 ff ff       	call   f0104016 <cprintf>
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
        //case查询 inc/syscall.h
        int32_t ret = 0;
f0104f90:	be 00 00 00 00       	mov    $0x0,%esi
f0104f95:	e9 cc 05 00 00       	jmp    f0105566 <syscall+0x63f>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104f9a:	e8 8d b6 ff ff       	call   f010062c <cons_getc>
f0104f9f:	89 c6                	mov    %eax,%esi
            case SYS_cputs: 
                sys_cputs((const char *)a1,a2);
                break;
            case SYS_cgetc:
                ret = sys_cgetc();
                break;
f0104fa1:	e9 c0 05 00 00       	jmp    f0105566 <syscall+0x63f>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104fa6:	e8 e1 17 00 00       	call   f010678c <cpunum>
f0104fab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104fb2:	29 c2                	sub    %eax,%edx
f0104fb4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fb7:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104fbe:	8b 70 48             	mov    0x48(%eax),%esi
            case SYS_cgetc:
                ret = sys_cgetc();
                break;
            case SYS_getenvid:
                ret = sys_getenvid();
                break;
f0104fc1:	e9 a0 05 00 00       	jmp    f0105566 <syscall+0x63f>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104fc6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fcd:	00 
f0104fce:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fd5:	89 34 24             	mov    %esi,(%esp)
f0104fd8:	e8 42 e6 ff ff       	call   f010361f <envid2env>
f0104fdd:	89 c6                	mov    %eax,%esi
f0104fdf:	85 c0                	test   %eax,%eax
f0104fe1:	0f 88 7f 05 00 00    	js     f0105566 <syscall+0x63f>
		return r;
	if (e == curenv)
f0104fe7:	e8 a0 17 00 00       	call   f010678c <cpunum>
f0104fec:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fef:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104ff6:	29 c1                	sub    %eax,%ecx
f0104ff8:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104ffb:	39 14 85 28 20 33 f0 	cmp    %edx,-0xfccdfd8(,%eax,4)
f0105002:	75 2d                	jne    f0105031 <syscall+0x10a>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0105004:	e8 83 17 00 00       	call   f010678c <cpunum>
f0105009:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105010:	29 c2                	sub    %eax,%edx
f0105012:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105015:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f010501c:	8b 40 48             	mov    0x48(%eax),%eax
f010501f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105023:	c7 04 24 0b 85 10 f0 	movl   $0xf010850b,(%esp)
f010502a:	e8 e7 ef ff ff       	call   f0104016 <cprintf>
f010502f:	eb 32                	jmp    f0105063 <syscall+0x13c>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105031:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105034:	e8 53 17 00 00       	call   f010678c <cpunum>
f0105039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010503d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105044:	29 c2                	sub    %eax,%edx
f0105046:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105049:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105050:	8b 40 48             	mov    0x48(%eax),%eax
f0105053:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105057:	c7 04 24 26 85 10 f0 	movl   $0xf0108526,(%esp)
f010505e:	e8 b3 ef ff ff       	call   f0104016 <cprintf>
	env_destroy(e);
f0105063:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105066:	89 04 24             	mov    %eax,(%esp)
f0105069:	e8 6b ec ff ff       	call   f0103cd9 <env_destroy>
	return 0;
f010506e:	be 00 00 00 00       	mov    $0x0,%esi
            case SYS_getenvid:
                ret = sys_getenvid();
                break;
            case SYS_env_destroy:
                ret = sys_env_destroy(a1);
                break;
f0105073:	e9 ee 04 00 00       	jmp    f0105566 <syscall+0x63f>
            case SYS_yield:
                sys_yield();
f0105078:	e8 9f fe ff ff       	call   f0104f1c <sys_yield>

	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");
        struct Env *e;
        envid_t ret;
        if((ret = env_alloc(&e,curenv->env_id)) < 0)
f010507d:	e8 0a 17 00 00       	call   f010678c <cpunum>
f0105082:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105089:	29 c2                	sub    %eax,%edx
f010508b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010508e:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105095:	8b 40 48             	mov    0x48(%eax),%eax
f0105098:	89 44 24 04          	mov    %eax,0x4(%esp)
f010509c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010509f:	89 04 24             	mov    %eax,(%esp)
f01050a2:	e8 ac e6 ff ff       	call   f0103753 <env_alloc>
f01050a7:	89 c6                	mov    %eax,%esi
f01050a9:	85 c0                	test   %eax,%eax
f01050ab:	0f 88 b5 04 00 00    	js     f0105566 <syscall+0x63f>
            return  ret;
        else{
            e->env_status = ENV_NOT_RUNNABLE;
f01050b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01050b4:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
            e->env_tf = curenv->env_tf;
f01050bb:	e8 cc 16 00 00       	call   f010678c <cpunum>
f01050c0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050c7:	29 c2                	sub    %eax,%edx
f01050c9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050cc:	8b 34 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%esi
f01050d3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01050d8:	89 df                	mov    %ebx,%edi
f01050da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            e->env_tf.tf_regs.reg_eax = 0;  //返回值放在eax
f01050dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01050df:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
            return  e->env_id;
f01050e6:	8b 70 48             	mov    0x48(%eax),%esi
            case SYS_yield:
                sys_yield();
                break;
            case SYS_exofork:
                ret = sys_exofork();
                break;
f01050e9:	e9 78 04 00 00       	jmp    f0105566 <syscall+0x63f>

	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");
        int ret;
        struct Env *e;
        if(!( status==ENV_RUNNABLE || status==ENV_NOT_RUNNABLE ))
f01050ee:	83 ff 02             	cmp    $0x2,%edi
f01050f1:	74 05                	je     f01050f8 <syscall+0x1d1>
f01050f3:	83 ff 04             	cmp    $0x4,%edi
f01050f6:	75 31                	jne    f0105129 <syscall+0x202>
            return -E_INVAL;
        if((ret = envid2env(envid, &e, 1)) < 0)
f01050f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050ff:	00 
f0105100:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105103:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105107:	89 34 24             	mov    %esi,(%esp)
f010510a:	e8 10 e5 ff ff       	call   f010361f <envid2env>
f010510f:	89 c6                	mov    %eax,%esi
f0105111:	85 c0                	test   %eax,%eax
f0105113:	0f 88 4d 04 00 00    	js     f0105566 <syscall+0x63f>
            return ret;
        else{
            e->env_status = status;
f0105119:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010511c:	89 78 54             	mov    %edi,0x54(%eax)
            return 0;
f010511f:	be 00 00 00 00       	mov    $0x0,%esi
f0105124:	e9 3d 04 00 00       	jmp    f0105566 <syscall+0x63f>
	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");
        int ret;
        struct Env *e;
        if(!( status==ENV_RUNNABLE || status==ENV_NOT_RUNNABLE ))
            return -E_INVAL;
f0105129:	be fd ff ff ff       	mov    $0xfffffffd,%esi
            case SYS_exofork:
                ret = sys_exofork();
                break;
	    case SYS_env_set_status:
                ret = sys_env_set_status(a1, a2);
                break;
f010512e:	e9 33 04 00 00       	jmp    f0105566 <syscall+0x63f>
	// LAB 4: Your code here.
	//panic("sys_page_alloc not implemented");
        int ret;
        struct Env* e;
        struct PageInfo *p;
        if((ret = envid2env(envid, &e ,1)) < 0)
f0105133:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010513a:	00 
f010513b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010513e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105142:	89 34 24             	mov    %esi,(%esp)
f0105145:	e8 d5 e4 ff ff       	call   f010361f <envid2env>
f010514a:	85 c0                	test   %eax,%eax
f010514c:	79 09                	jns    f0105157 <syscall+0x230>
            return -ret; 
f010514e:	89 c6                	mov    %eax,%esi
f0105150:	f7 de                	neg    %esi
f0105152:	e9 0f 04 00 00       	jmp    f0105566 <syscall+0x63f>
        if((int)va >= UTOP || ((int)va%PGSIZE))
f0105157:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010515d:	77 5d                	ja     f01051bc <syscall+0x295>
f010515f:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105165:	75 5f                	jne    f01051c6 <syscall+0x29f>
            return -E_INVAL;
        if(!(perm & PTE_U) || !(perm & PTE_P))
f0105167:	89 d8                	mov    %ebx,%eax
f0105169:	83 e0 05             	and    $0x5,%eax
f010516c:	83 f8 05             	cmp    $0x5,%eax
f010516f:	75 5f                	jne    f01051d0 <syscall+0x2a9>
            return -E_INVAL;
        if((perm & ~PTE_SYSCALL) > 0)
f0105171:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f0105177:	7f 61                	jg     f01051da <syscall+0x2b3>
            return -E_INVAL;
        if(!(p = page_alloc(1)))
f0105179:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105180:	e8 38 be ff ff       	call   f0100fbd <page_alloc>
f0105185:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105188:	85 c0                	test   %eax,%eax
f010518a:	74 58                	je     f01051e4 <syscall+0x2bd>
            return -E_NO_MEM;
        if((ret = page_insert(e->env_pgdir, p, va, perm)) < 0){
f010518c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105190:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105194:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105198:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010519b:	8b 40 60             	mov    0x60(%eax),%eax
f010519e:	89 04 24             	mov    %eax,(%esp)
f01051a1:	e8 8a c1 ff ff       	call   f0101330 <page_insert>
f01051a6:	89 c6                	mov    %eax,%esi
f01051a8:	85 c0                	test   %eax,%eax
f01051aa:	79 42                	jns    f01051ee <syscall+0x2c7>
            page_free(p);
f01051ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01051af:	89 04 24             	mov    %eax,(%esp)
f01051b2:	e8 8a be ff ff       	call   f0101041 <page_free>
f01051b7:	e9 aa 03 00 00       	jmp    f0105566 <syscall+0x63f>
        struct Env* e;
        struct PageInfo *p;
        if((ret = envid2env(envid, &e ,1)) < 0)
            return -ret; 
        if((int)va >= UTOP || ((int)va%PGSIZE))
            return -E_INVAL;
f01051bc:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01051c1:	e9 a0 03 00 00       	jmp    f0105566 <syscall+0x63f>
f01051c6:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01051cb:	e9 96 03 00 00       	jmp    f0105566 <syscall+0x63f>
        if(!(perm & PTE_U) || !(perm & PTE_P))
            return -E_INVAL;
f01051d0:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01051d5:	e9 8c 03 00 00       	jmp    f0105566 <syscall+0x63f>
        if((perm & ~PTE_SYSCALL) > 0)
            return -E_INVAL;
f01051da:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01051df:	e9 82 03 00 00       	jmp    f0105566 <syscall+0x63f>
        if(!(p = page_alloc(1)))
            return -E_NO_MEM;
f01051e4:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01051e9:	e9 78 03 00 00       	jmp    f0105566 <syscall+0x63f>
        if((ret = page_insert(e->env_pgdir, p, va, perm)) < 0){
            page_free(p);
            return ret;
        }
        return 0;
f01051ee:	be 00 00 00 00       	mov    $0x0,%esi
	    case SYS_env_set_status:
                ret = sys_env_set_status(a1, a2);
                break;
	    case SYS_page_alloc:
                ret = sys_page_alloc(a1, (void *)a2, a3);
                break;
f01051f3:	e9 6e 03 00 00       	jmp    f0105566 <syscall+0x63f>
	//panic("sys_page_map not implemented");
        int ret = 0;
        struct Env *src_env,*dst_env;
        struct PageInfo *p;
        pte_t *pte;
        if((ret = envid2env(srcenvid, &src_env, 1)) < 0)
f01051f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051ff:	00 
f0105200:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105203:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105207:	89 34 24             	mov    %esi,(%esp)
f010520a:	e8 10 e4 ff ff       	call   f010361f <envid2env>
f010520f:	89 c6                	mov    %eax,%esi
f0105211:	85 c0                	test   %eax,%eax
f0105213:	0f 88 4d 03 00 00    	js     f0105566 <syscall+0x63f>
            return ret;
        if((ret = envid2env(dstenvid, &dst_env, 1)) < 0)
f0105219:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105220:	00 
f0105221:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105224:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105228:	89 1c 24             	mov    %ebx,(%esp)
f010522b:	e8 ef e3 ff ff       	call   f010361f <envid2env>
f0105230:	89 c6                	mov    %eax,%esi
f0105232:	85 c0                	test   %eax,%eax
f0105234:	0f 88 2c 03 00 00    	js     f0105566 <syscall+0x63f>
            return ret;
        if((int)srcva >= UTOP || (int)srcva%PGSIZE)
f010523a:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105240:	0f 87 99 00 00 00    	ja     f01052df <syscall+0x3b8>
f0105246:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010524c:	0f 85 97 00 00 00    	jne    f01052e9 <syscall+0x3c2>
            return -E_INVAL;
        if((int)dstva >= UTOP || (int)dstva%PGSIZE)
f0105252:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105259:	0f 87 94 00 00 00    	ja     f01052f3 <syscall+0x3cc>
f010525f:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105266:	0f 85 91 00 00 00    	jne    f01052fd <syscall+0x3d6>
            return -E_INVAL;
        if((p = page_lookup(src_env->env_pgdir, srcva, &pte)) == NULL)
f010526c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010526f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105273:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105277:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010527a:	8b 40 60             	mov    0x60(%eax),%eax
f010527d:	89 04 24             	mov    %eax,(%esp)
f0105280:	e8 88 bf ff ff       	call   f010120d <page_lookup>
f0105285:	85 c0                	test   %eax,%eax
f0105287:	74 7e                	je     f0105307 <syscall+0x3e0>
                return -E_INVAL;
        if(!(perm & PTE_U) || !(perm & PTE_P))
f0105289:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010528c:	83 e2 05             	and    $0x5,%edx
f010528f:	83 fa 05             	cmp    $0x5,%edx
f0105292:	75 7d                	jne    f0105311 <syscall+0x3ea>
            return -E_INVAL;
        //int perm_flag = PTE_U | PTE_P | PTE_AVAIL | PTE_W;
        if((perm & ~PTE_SYSCALL) > 0)
f0105294:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f010529b:	7f 7e                	jg     f010531b <syscall+0x3f4>
            return -E_INVAL;
        if((perm & PTE_W) && ((*pte & PTE_W)==0))
f010529d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01052a1:	74 08                	je     f01052ab <syscall+0x384>
f01052a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01052a6:	f6 02 02             	testb  $0x2,(%edx)
f01052a9:	74 7a                	je     f0105325 <syscall+0x3fe>
            return -E_INVAL;
        if((ret = page_insert(dst_env->env_pgdir, p, dstva, perm)) < 0)
f01052ab:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01052ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01052b2:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01052b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01052b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052c0:	8b 40 60             	mov    0x60(%eax),%eax
f01052c3:	89 04 24             	mov    %eax,(%esp)
f01052c6:	e8 65 c0 ff ff       	call   f0101330 <page_insert>
f01052cb:	89 c6                	mov    %eax,%esi
f01052cd:	85 c0                	test   %eax,%eax
f01052cf:	0f 8e 91 02 00 00    	jle    f0105566 <syscall+0x63f>
f01052d5:	be 00 00 00 00       	mov    $0x0,%esi
f01052da:	e9 87 02 00 00       	jmp    f0105566 <syscall+0x63f>
        if((ret = envid2env(srcenvid, &src_env, 1)) < 0)
            return ret;
        if((ret = envid2env(dstenvid, &dst_env, 1)) < 0)
            return ret;
        if((int)srcva >= UTOP || (int)srcva%PGSIZE)
            return -E_INVAL;
f01052df:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052e4:	e9 7d 02 00 00       	jmp    f0105566 <syscall+0x63f>
f01052e9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052ee:	e9 73 02 00 00       	jmp    f0105566 <syscall+0x63f>
        if((int)dstva >= UTOP || (int)dstva%PGSIZE)
            return -E_INVAL;
f01052f3:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052f8:	e9 69 02 00 00       	jmp    f0105566 <syscall+0x63f>
f01052fd:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105302:	e9 5f 02 00 00       	jmp    f0105566 <syscall+0x63f>
        if((p = page_lookup(src_env->env_pgdir, srcva, &pte)) == NULL)
                return -E_INVAL;
f0105307:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010530c:	e9 55 02 00 00       	jmp    f0105566 <syscall+0x63f>
        if(!(perm & PTE_U) || !(perm & PTE_P))
            return -E_INVAL;
f0105311:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105316:	e9 4b 02 00 00       	jmp    f0105566 <syscall+0x63f>
        //int perm_flag = PTE_U | PTE_P | PTE_AVAIL | PTE_W;
        if((perm & ~PTE_SYSCALL) > 0)
            return -E_INVAL;
f010531b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105320:	e9 41 02 00 00       	jmp    f0105566 <syscall+0x63f>
        if((perm & PTE_W) && ((*pte & PTE_W)==0))
            return -E_INVAL;
f0105325:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	    case SYS_page_alloc:
                ret = sys_page_alloc(a1, (void *)a2, a3);
                break;
            case SYS_page_map:
                ret = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
f010532a:	e9 37 02 00 00       	jmp    f0105566 <syscall+0x63f>

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
        int ret;
        struct Env* e;
        if((ret = envid2env(envid, &e, 1)) < 0)
f010532f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105336:	00 
f0105337:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010533a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010533e:	89 34 24             	mov    %esi,(%esp)
f0105341:	e8 d9 e2 ff ff       	call   f010361f <envid2env>
f0105346:	89 c6                	mov    %eax,%esi
f0105348:	85 c0                	test   %eax,%eax
f010534a:	0f 88 16 02 00 00    	js     f0105566 <syscall+0x63f>
            return ret;
        if((int)va >= UTOP || ((int)va%PGSIZE))
f0105350:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105356:	77 24                	ja     f010537c <syscall+0x455>
f0105358:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010535e:	75 26                	jne    f0105386 <syscall+0x45f>
            return -E_INVAL;
        page_remove( e->env_pgdir, va);
f0105360:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105367:	8b 40 60             	mov    0x60(%eax),%eax
f010536a:	89 04 24             	mov    %eax,(%esp)
f010536d:	e8 51 bf ff ff       	call   f01012c3 <page_remove>
        return 0;
f0105372:	be 00 00 00 00       	mov    $0x0,%esi
f0105377:	e9 ea 01 00 00       	jmp    f0105566 <syscall+0x63f>
        int ret;
        struct Env* e;
        if((ret = envid2env(envid, &e, 1)) < 0)
            return ret;
        if((int)va >= UTOP || ((int)va%PGSIZE))
            return -E_INVAL;
f010537c:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105381:	e9 e0 01 00 00       	jmp    f0105566 <syscall+0x63f>
f0105386:	be fd ff ff ff       	mov    $0xfffffffd,%esi
            case SYS_page_map:
                ret = sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
                break;
            case SYS_page_unmap:
                ret = sys_page_unmap(a1, (void *)a2);
                break;
f010538b:	e9 d6 01 00 00       	jmp    f0105566 <syscall+0x63f>
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");
        int ret;
        struct Env *e;
        if((ret = envid2env(envid, &e, 1)) < 0)
f0105390:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105397:	00 
f0105398:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010539b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010539f:	89 34 24             	mov    %esi,(%esp)
f01053a2:	e8 78 e2 ff ff       	call   f010361f <envid2env>
f01053a7:	89 c6                	mov    %eax,%esi
f01053a9:	85 c0                	test   %eax,%eax
f01053ab:	0f 88 b5 01 00 00    	js     f0105566 <syscall+0x63f>
            return ret;
        e->env_pgfault_upcall = func;
f01053b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053b4:	89 78 64             	mov    %edi,0x64(%eax)
f01053b7:	e9 aa 01 00 00       	jmp    f0105566 <syscall+0x63f>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");
        if(dstva < (void *)UTOP){
f01053bc:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01053c2:	77 0c                	ja     f01053d0 <syscall+0x4a9>
            if((int)dstva%PGSIZE)
f01053c4:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f01053ca:	0f 85 91 01 00 00    	jne    f0105561 <syscall+0x63a>
                return -E_INVAL;
        }
        curenv->env_ipc_recving = true;
f01053d0:	e8 b7 13 00 00       	call   f010678c <cpunum>
f01053d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01053d8:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01053de:	c6 40 68 01          	movb   $0x1,0x68(%eax)
        curenv->env_ipc_dstva = dstva;
f01053e2:	e8 a5 13 00 00       	call   f010678c <cpunum>
f01053e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ea:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01053f0:	89 70 6c             	mov    %esi,0x6c(%eax)
        curenv->env_status = ENV_NOT_RUNNABLE;
f01053f3:	e8 94 13 00 00       	call   f010678c <cpunum>
f01053f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01053fb:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0105401:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        sys_yield();
f0105408:	e8 0f fb ff ff       	call   f0104f1c <sys_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *e;
        if(envid2env(envid, &e, 0) < 0)
f010540d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105414:	00 
f0105415:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105418:	89 44 24 04          	mov    %eax,0x4(%esp)
f010541c:	89 34 24             	mov    %esi,(%esp)
f010541f:	e8 fb e1 ff ff       	call   f010361f <envid2env>
f0105424:	85 c0                	test   %eax,%eax
f0105426:	0f 88 f6 00 00 00    	js     f0105522 <syscall+0x5fb>
            return -E_BAD_ENV;
        if(e->env_ipc_recving==0 )//|| e->env_ipc_from!=0)
f010542c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010542f:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105433:	0f 84 f0 00 00 00    	je     f0105529 <syscall+0x602>
            return -E_IPC_NOT_RECV;
        if(srcva < (void *)UTOP){
f0105439:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010543f:	0f 87 9d 00 00 00    	ja     f01054e2 <syscall+0x5bb>
            if((int)srcva%PGSIZE )
f0105445:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010544b:	0f 85 df 00 00 00    	jne    f0105530 <syscall+0x609>
                return -E_INVAL;
            if(!(perm & PTE_U) || !(perm & PTE_P))
f0105451:	8b 45 18             	mov    0x18(%ebp),%eax
f0105454:	83 e0 05             	and    $0x5,%eax
f0105457:	83 f8 05             	cmp    $0x5,%eax
f010545a:	0f 85 d7 00 00 00    	jne    f0105537 <syscall+0x610>
                return -E_INVAL;
            if((perm & ~PTE_SYSCALL) > 0)
f0105460:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0105467:	0f 85 d1 00 00 00    	jne    f010553e <syscall+0x617>
                return -E_INVAL;
            pte_t *pte;
            struct PageInfo *p;
            if((p = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
f010546d:	e8 1a 13 00 00       	call   f010678c <cpunum>
f0105472:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105475:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105479:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010547d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105484:	29 c2                	sub    %eax,%edx
f0105486:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105489:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105490:	8b 40 60             	mov    0x60(%eax),%eax
f0105493:	89 04 24             	mov    %eax,(%esp)
f0105496:	e8 72 bd ff ff       	call   f010120d <page_lookup>
f010549b:	85 c0                	test   %eax,%eax
f010549d:	0f 84 a2 00 00 00    	je     f0105545 <syscall+0x61e>
                return -E_INVAL;
            if((perm & PTE_W) && (*pte&PTE_W)==0)
f01054a3:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01054a7:	74 0c                	je     f01054b5 <syscall+0x58e>
f01054a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01054ac:	f6 02 02             	testb  $0x2,(%edx)
f01054af:	0f 84 97 00 00 00    	je     f010554c <syscall+0x625>
                return -E_INVAL;
            if(page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm) < 0)
f01054b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054b8:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01054bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01054bf:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01054c2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01054c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054ca:	8b 42 60             	mov    0x60(%edx),%eax
f01054cd:	89 04 24             	mov    %eax,(%esp)
f01054d0:	e8 5b be ff ff       	call   f0101330 <page_insert>
f01054d5:	85 c0                	test   %eax,%eax
f01054d7:	78 7a                	js     f0105553 <syscall+0x62c>
                return -E_NO_MEM;
            
            e->env_ipc_perm = perm;
f01054d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054dc:	8b 55 18             	mov    0x18(%ebp),%edx
f01054df:	89 50 78             	mov    %edx,0x78(%eax)
        }
        e->env_ipc_recving = 0;
f01054e2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01054e5:	c6 46 68 00          	movb   $0x0,0x68(%esi)
        e->env_ipc_from = curenv->env_id;
f01054e9:	e8 9e 12 00 00       	call   f010678c <cpunum>
f01054ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01054f5:	29 c2                	sub    %eax,%edx
f01054f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01054fa:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105501:	8b 40 48             	mov    0x48(%eax),%eax
f0105504:	89 46 74             	mov    %eax,0x74(%esi)
        e->env_ipc_value = value;
f0105507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010550a:	89 78 70             	mov    %edi,0x70(%eax)
        e->env_tf.tf_regs.reg_eax = 0;
f010550d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        e->env_status = ENV_RUNNABLE;
f0105514:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
        return 0;
f010551b:	be 00 00 00 00       	mov    $0x0,%esi
f0105520:	eb 44                	jmp    f0105566 <syscall+0x63f>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
        struct Env *e;
        if(envid2env(envid, &e, 0) < 0)
            return -E_BAD_ENV;
f0105522:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105527:	eb 3d                	jmp    f0105566 <syscall+0x63f>
        if(e->env_ipc_recving==0 )//|| e->env_ipc_from!=0)
            return -E_IPC_NOT_RECV;
f0105529:	be f8 ff ff ff       	mov    $0xfffffff8,%esi
f010552e:	eb 36                	jmp    f0105566 <syscall+0x63f>
        if(srcva < (void *)UTOP){
            if((int)srcva%PGSIZE )
                return -E_INVAL;
f0105530:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105535:	eb 2f                	jmp    f0105566 <syscall+0x63f>
            if(!(perm & PTE_U) || !(perm & PTE_P))
                return -E_INVAL;
f0105537:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010553c:	eb 28                	jmp    f0105566 <syscall+0x63f>
            if((perm & ~PTE_SYSCALL) > 0)
                return -E_INVAL;
f010553e:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105543:	eb 21                	jmp    f0105566 <syscall+0x63f>
            pte_t *pte;
            struct PageInfo *p;
            if((p = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL)
                return -E_INVAL;
f0105545:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010554a:	eb 1a                	jmp    f0105566 <syscall+0x63f>
            if((perm & PTE_W) && (*pte&PTE_W)==0)
                return -E_INVAL;
f010554c:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105551:	eb 13                	jmp    f0105566 <syscall+0x63f>
            if(page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm) < 0)
                return -E_NO_MEM;
f0105553:	be fc ff ff ff       	mov    $0xfffffffc,%esi
            case SYS_ipc_recv:
                ret = sys_ipc_recv((void *)a1);
                break;
            case SYS_ipc_try_send:
                ret = sys_ipc_try_send(a1, a2, (void *)a3, a4);
                break;
f0105558:	eb 0c                	jmp    f0105566 <syscall+0x63f>
            default:
		return -E_NO_SYS;
f010555a:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f010555f:	eb 05                	jmp    f0105566 <syscall+0x63f>
                break;
            case SYS_env_set_pgfault_upcall:
                ret = sys_env_set_pgfault_upcall(a1, (void*)a2);
                break;
            case SYS_ipc_recv:
                ret = sys_ipc_recv((void *)a1);
f0105561:	be fd ff ff ff       	mov    $0xfffffffd,%esi
                break;
            default:
		return -E_NO_SYS;
	}
        return ret;
}
f0105566:	89 f0                	mov    %esi,%eax
f0105568:	83 c4 3c             	add    $0x3c,%esp
f010556b:	5b                   	pop    %ebx
f010556c:	5e                   	pop    %esi
f010556d:	5f                   	pop    %edi
f010556e:	5d                   	pop    %ebp
f010556f:	c3                   	ret    

f0105570 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105570:	55                   	push   %ebp
f0105571:	89 e5                	mov    %esp,%ebp
f0105573:	57                   	push   %edi
f0105574:	56                   	push   %esi
f0105575:	53                   	push   %ebx
f0105576:	83 ec 14             	sub    $0x14,%esp
f0105579:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010557c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010557f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105582:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105585:	8b 1a                	mov    (%edx),%ebx
f0105587:	8b 01                	mov    (%ecx),%eax
f0105589:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010558c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0105593:	e9 83 00 00 00       	jmp    f010561b <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0105598:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010559b:	01 d8                	add    %ebx,%eax
f010559d:	89 c7                	mov    %eax,%edi
f010559f:	c1 ef 1f             	shr    $0x1f,%edi
f01055a2:	01 c7                	add    %eax,%edi
f01055a4:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01055a6:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01055a9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01055ac:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01055b0:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01055b2:	eb 01                	jmp    f01055b5 <stab_binsearch+0x45>
			m--;
f01055b4:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01055b5:	39 c3                	cmp    %eax,%ebx
f01055b7:	7f 1e                	jg     f01055d7 <stab_binsearch+0x67>
f01055b9:	0f b6 0a             	movzbl (%edx),%ecx
f01055bc:	83 ea 0c             	sub    $0xc,%edx
f01055bf:	39 f1                	cmp    %esi,%ecx
f01055c1:	75 f1                	jne    f01055b4 <stab_binsearch+0x44>
f01055c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01055c6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01055c9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01055cc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01055d0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01055d3:	76 18                	jbe    f01055ed <stab_binsearch+0x7d>
f01055d5:	eb 05                	jmp    f01055dc <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01055d7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01055da:	eb 3f                	jmp    f010561b <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01055dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055df:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01055e1:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055e4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01055eb:	eb 2e                	jmp    f010561b <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01055ed:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01055f0:	73 15                	jae    f0105607 <stab_binsearch+0x97>
			*region_right = m - 1;
f01055f2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01055f5:	49                   	dec    %ecx
f01055f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01055f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055fc:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055fe:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105605:	eb 14                	jmp    f010561b <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105607:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010560a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010560d:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010560f:	ff 45 0c             	incl   0xc(%ebp)
f0105612:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105614:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010561b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010561e:	0f 8e 74 ff ff ff    	jle    f0105598 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105624:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105628:	75 0d                	jne    f0105637 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010562a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010562d:	8b 02                	mov    (%edx),%eax
f010562f:	48                   	dec    %eax
f0105630:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105633:	89 01                	mov    %eax,(%ecx)
f0105635:	eb 2a                	jmp    f0105661 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105637:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010563a:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010563c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010563f:	8b 0a                	mov    (%edx),%ecx
f0105641:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105644:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0105647:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010564b:	eb 01                	jmp    f010564e <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010564d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010564e:	39 c8                	cmp    %ecx,%eax
f0105650:	7e 0a                	jle    f010565c <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0105652:	0f b6 1a             	movzbl (%edx),%ebx
f0105655:	83 ea 0c             	sub    $0xc,%edx
f0105658:	39 f3                	cmp    %esi,%ebx
f010565a:	75 f1                	jne    f010564d <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f010565c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010565f:	89 02                	mov    %eax,(%edx)
	}
}
f0105661:	83 c4 14             	add    $0x14,%esp
f0105664:	5b                   	pop    %ebx
f0105665:	5e                   	pop    %esi
f0105666:	5f                   	pop    %edi
f0105667:	5d                   	pop    %ebp
f0105668:	c3                   	ret    

f0105669 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105669:	55                   	push   %ebp
f010566a:	89 e5                	mov    %esp,%ebp
f010566c:	57                   	push   %edi
f010566d:	56                   	push   %esi
f010566e:	53                   	push   %ebx
f010566f:	83 ec 5c             	sub    $0x5c,%esp
f0105672:	8b 75 08             	mov    0x8(%ebp),%esi
f0105675:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105678:	c7 03 74 85 10 f0    	movl   $0xf0108574,(%ebx)
	info->eip_line = 0;
f010567e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105685:	c7 43 08 74 85 10 f0 	movl   $0xf0108574,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010568c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105693:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105696:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010569d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01056a3:	0f 87 0f 01 00 00    	ja     f01057b8 <debuginfo_eip+0x14f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

                if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f01056a9:	e8 de 10 00 00       	call   f010678c <cpunum>
f01056ae:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01056b5:	00 
f01056b6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01056bd:	00 
f01056be:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01056c5:	00 
f01056c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056cd:	29 c2                	sub    %eax,%edx
f01056cf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056d2:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01056d9:	89 04 24             	mov    %eax,(%esp)
f01056dc:	e8 c5 dd ff ff       	call   f01034a6 <user_mem_check>
f01056e1:	85 c0                	test   %eax,%eax
f01056e3:	0f 88 85 02 00 00    	js     f010596e <debuginfo_eip+0x305>
                    return -1;

		stabs = usd->stabs;
f01056e9:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01056ef:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01056f2:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01056f8:	a1 08 00 20 00       	mov    0x200008,%eax
f01056fd:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105700:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105706:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                
                if((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0) 
f0105709:	e8 7e 10 00 00       	call   f010678c <cpunum>
f010570e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105715:	00 
f0105716:	89 fa                	mov    %edi,%edx
f0105718:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f010571b:	c1 fa 02             	sar    $0x2,%edx
f010571e:	8d 0c 92             	lea    (%edx,%edx,4),%ecx
f0105721:	8d 0c 8a             	lea    (%edx,%ecx,4),%ecx
f0105724:	8d 0c 8a             	lea    (%edx,%ecx,4),%ecx
f0105727:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f010572a:	c1 e1 08             	shl    $0x8,%ecx
f010572d:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0105730:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0105733:	03 4d b8             	add    -0x48(%ebp),%ecx
f0105736:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f0105739:	c1 e1 10             	shl    $0x10,%ecx
f010573c:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f010573f:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0105742:	03 4d b8             	add    -0x48(%ebp),%ecx
f0105745:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
f0105748:	89 54 24 08          	mov    %edx,0x8(%esp)
f010574c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010574f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105753:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010575a:	29 c2                	sub    %eax,%edx
f010575c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010575f:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105766:	89 04 24             	mov    %eax,(%esp)
f0105769:	e8 38 dd ff ff       	call   f01034a6 <user_mem_check>
f010576e:	85 c0                	test   %eax,%eax
f0105770:	0f 88 ff 01 00 00    	js     f0105975 <debuginfo_eip+0x30c>
                    || user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105776:	e8 11 10 00 00       	call   f010678c <cpunum>
f010577b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105782:	00 
f0105783:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105786:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105789:	89 54 24 08          	mov    %edx,0x8(%esp)
f010578d:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105790:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105794:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010579b:	29 c2                	sub    %eax,%edx
f010579d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01057a0:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01057a7:	89 04 24             	mov    %eax,(%esp)
f01057aa:	e8 f7 dc ff ff       	call   f01034a6 <user_mem_check>
f01057af:	85 c0                	test   %eax,%eax
f01057b1:	79 1f                	jns    f01057d2 <debuginfo_eip+0x169>
f01057b3:	e9 c4 01 00 00       	jmp    f010597c <debuginfo_eip+0x313>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01057b8:	c7 45 c0 25 e9 11 f0 	movl   $0xf011e925,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01057bf:	c7 45 bc ed 3d 11 f0 	movl   $0xf0113ded,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01057c6:	bf ec 3d 11 f0       	mov    $0xf0113dec,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01057cb:	c7 45 c4 58 8a 10 f0 	movl   $0xf0108a58,-0x3c(%ebp)
                    return -1;
                    
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01057d2:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01057d5:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01057d8:	0f 83 a5 01 00 00    	jae    f0105983 <debuginfo_eip+0x31a>
f01057de:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01057e2:	0f 85 a2 01 00 00    	jne    f010598a <debuginfo_eip+0x321>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01057e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01057ef:	89 f8                	mov    %edi,%eax
f01057f1:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f01057f4:	c1 f8 02             	sar    $0x2,%eax
f01057f7:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01057fa:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01057fd:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105800:	89 d1                	mov    %edx,%ecx
f0105802:	c1 e1 08             	shl    $0x8,%ecx
f0105805:	01 ca                	add    %ecx,%edx
f0105807:	89 d1                	mov    %edx,%ecx
f0105809:	c1 e1 10             	shl    $0x10,%ecx
f010580c:	01 ca                	add    %ecx,%edx
f010580e:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f0105812:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105815:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105819:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105820:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105823:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105826:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105829:	e8 42 fd ff ff       	call   f0105570 <stab_binsearch>
	if (lfile == 0)
f010582e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105831:	85 c0                	test   %eax,%eax
f0105833:	0f 84 58 01 00 00    	je     f0105991 <debuginfo_eip+0x328>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105839:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010583c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010583f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105842:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105846:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010584d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105850:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105853:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105856:	e8 15 fd ff ff       	call   f0105570 <stab_binsearch>

	if (lfun <= rfun) {
f010585b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010585e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105861:	39 d0                	cmp    %edx,%eax
f0105863:	7f 32                	jg     f0105897 <debuginfo_eip+0x22e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105865:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105868:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010586b:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010586e:	8b 39                	mov    (%ecx),%edi
f0105870:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105873:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105876:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105879:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010587c:	73 09                	jae    f0105887 <debuginfo_eip+0x21e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010587e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105881:	03 7d bc             	add    -0x44(%ebp),%edi
f0105884:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105887:	8b 49 08             	mov    0x8(%ecx),%ecx
f010588a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010588d:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010588f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105892:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105895:	eb 0f                	jmp    f01058a6 <debuginfo_eip+0x23d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105897:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010589a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010589d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01058a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01058a6:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01058ad:	00 
f01058ae:	8b 43 08             	mov    0x8(%ebx),%eax
f01058b1:	89 04 24             	mov    %eax,(%esp)
f01058b4:	e8 8d 08 00 00       	call   f0106146 <strfind>
f01058b9:	2b 43 08             	sub    0x8(%ebx),%eax
f01058bc:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01058bf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01058c3:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01058ca:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01058cd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01058d0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01058d3:	e8 98 fc ff ff       	call   f0105570 <stab_binsearch>
        if (lline > rline)
f01058d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01058db:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01058de:	0f 8f b4 00 00 00    	jg     f0105998 <debuginfo_eip+0x32f>
            return -1;
        info->eip_line = stabs[rline].n_desc;
f01058e4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01058e7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01058ea:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01058ef:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01058f2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01058f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01058f8:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01058fb:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f01058ff:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105902:	eb 04                	jmp    f0105908 <debuginfo_eip+0x29f>
f0105904:	48                   	dec    %eax
f0105905:	83 ea 0c             	sub    $0xc,%edx
f0105908:	89 c7                	mov    %eax,%edi
f010590a:	39 c6                	cmp    %eax,%esi
f010590c:	7f 28                	jg     f0105936 <debuginfo_eip+0x2cd>
	       && stabs[lline].n_type != N_SOL
f010590e:	8a 4a fc             	mov    -0x4(%edx),%cl
f0105911:	80 f9 84             	cmp    $0x84,%cl
f0105914:	0f 84 99 00 00 00    	je     f01059b3 <debuginfo_eip+0x34a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010591a:	80 f9 64             	cmp    $0x64,%cl
f010591d:	75 e5                	jne    f0105904 <debuginfo_eip+0x29b>
f010591f:	83 3a 00             	cmpl   $0x0,(%edx)
f0105922:	74 e0                	je     f0105904 <debuginfo_eip+0x29b>
f0105924:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105927:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010592a:	e9 8a 00 00 00       	jmp    f01059b9 <debuginfo_eip+0x350>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010592f:	03 45 bc             	add    -0x44(%ebp),%eax
f0105932:	89 03                	mov    %eax,(%ebx)
f0105934:	eb 03                	jmp    f0105939 <debuginfo_eip+0x2d0>
f0105936:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105939:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010593c:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010593f:	39 f2                	cmp    %esi,%edx
f0105941:	7d 5c                	jge    f010599f <debuginfo_eip+0x336>
		for (lline = lfun + 1;
f0105943:	42                   	inc    %edx
f0105944:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105947:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105949:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010594c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010594f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105953:	eb 03                	jmp    f0105958 <debuginfo_eip+0x2ef>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105955:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105958:	39 f0                	cmp    %esi,%eax
f010595a:	7d 4a                	jge    f01059a6 <debuginfo_eip+0x33d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010595c:	8a 0a                	mov    (%edx),%cl
f010595e:	40                   	inc    %eax
f010595f:	83 c2 0c             	add    $0xc,%edx
f0105962:	80 f9 a0             	cmp    $0xa0,%cl
f0105965:	74 ee                	je     f0105955 <debuginfo_eip+0x2ec>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105967:	b8 00 00 00 00       	mov    $0x0,%eax
f010596c:	eb 3d                	jmp    f01059ab <debuginfo_eip+0x342>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

                if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
                    return -1;
f010596e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105973:	eb 36                	jmp    f01059ab <debuginfo_eip+0x342>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
                
                if((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0) 
                    || user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
                    return -1;
f0105975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010597a:	eb 2f                	jmp    f01059ab <debuginfo_eip+0x342>
f010597c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105981:	eb 28                	jmp    f01059ab <debuginfo_eip+0x342>
                    
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105988:	eb 21                	jmp    f01059ab <debuginfo_eip+0x342>
f010598a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010598f:	eb 1a                	jmp    f01059ab <debuginfo_eip+0x342>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105991:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105996:	eb 13                	jmp    f01059ab <debuginfo_eip+0x342>
	//	which one.
	// Your code here.

        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
        if (lline > rline)
            return -1;
f0105998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010599d:	eb 0c                	jmp    f01059ab <debuginfo_eip+0x342>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010599f:	b8 00 00 00 00       	mov    $0x0,%eax
f01059a4:	eb 05                	jmp    f01059ab <debuginfo_eip+0x342>
f01059a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059ab:	83 c4 5c             	add    $0x5c,%esp
f01059ae:	5b                   	pop    %ebx
f01059af:	5e                   	pop    %esi
f01059b0:	5f                   	pop    %edi
f01059b1:	5d                   	pop    %ebp
f01059b2:	c3                   	ret    
f01059b3:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01059b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01059b9:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01059bc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01059bf:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01059c2:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01059c5:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01059c8:	39 d0                	cmp    %edx,%eax
f01059ca:	0f 82 5f ff ff ff    	jb     f010592f <debuginfo_eip+0x2c6>
f01059d0:	e9 64 ff ff ff       	jmp    f0105939 <debuginfo_eip+0x2d0>
f01059d5:	00 00                	add    %al,(%eax)
	...

f01059d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01059d8:	55                   	push   %ebp
f01059d9:	89 e5                	mov    %esp,%ebp
f01059db:	57                   	push   %edi
f01059dc:	56                   	push   %esi
f01059dd:	53                   	push   %ebx
f01059de:	83 ec 3c             	sub    $0x3c,%esp
f01059e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01059e4:	89 d7                	mov    %edx,%edi
f01059e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01059e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01059ec:	8b 45 0c             	mov    0xc(%ebp),%eax
f01059ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01059f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01059f5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01059f8:	85 c0                	test   %eax,%eax
f01059fa:	75 08                	jne    f0105a04 <printnum+0x2c>
f01059fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059ff:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105a02:	77 57                	ja     f0105a5b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105a04:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105a08:	4b                   	dec    %ebx
f0105a09:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105a0d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a10:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a14:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105a18:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105a1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105a23:	00 
f0105a24:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a27:	89 04 24             	mov    %eax,(%esp)
f0105a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a31:	e8 c6 11 00 00       	call   f0106bfc <__udivdi3>
f0105a36:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105a3a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105a3e:	89 04 24             	mov    %eax,(%esp)
f0105a41:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a45:	89 fa                	mov    %edi,%edx
f0105a47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a4a:	e8 89 ff ff ff       	call   f01059d8 <printnum>
f0105a4f:	eb 0f                	jmp    f0105a60 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105a51:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a55:	89 34 24             	mov    %esi,(%esp)
f0105a58:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105a5b:	4b                   	dec    %ebx
f0105a5c:	85 db                	test   %ebx,%ebx
f0105a5e:	7f f1                	jg     f0105a51 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105a60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a64:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105a68:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105a76:	00 
f0105a77:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a7a:	89 04 24             	mov    %eax,(%esp)
f0105a7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a84:	e8 93 12 00 00       	call   f0106d1c <__umoddi3>
f0105a89:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a8d:	0f be 80 7e 85 10 f0 	movsbl -0xfef7a82(%eax),%eax
f0105a94:	89 04 24             	mov    %eax,(%esp)
f0105a97:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105a9a:	83 c4 3c             	add    $0x3c,%esp
f0105a9d:	5b                   	pop    %ebx
f0105a9e:	5e                   	pop    %esi
f0105a9f:	5f                   	pop    %edi
f0105aa0:	5d                   	pop    %ebp
f0105aa1:	c3                   	ret    

f0105aa2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105aa2:	55                   	push   %ebp
f0105aa3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105aa5:	83 fa 01             	cmp    $0x1,%edx
f0105aa8:	7e 0e                	jle    f0105ab8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105aaa:	8b 10                	mov    (%eax),%edx
f0105aac:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105aaf:	89 08                	mov    %ecx,(%eax)
f0105ab1:	8b 02                	mov    (%edx),%eax
f0105ab3:	8b 52 04             	mov    0x4(%edx),%edx
f0105ab6:	eb 22                	jmp    f0105ada <getuint+0x38>
	else if (lflag)
f0105ab8:	85 d2                	test   %edx,%edx
f0105aba:	74 10                	je     f0105acc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105abc:	8b 10                	mov    (%eax),%edx
f0105abe:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105ac1:	89 08                	mov    %ecx,(%eax)
f0105ac3:	8b 02                	mov    (%edx),%eax
f0105ac5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105aca:	eb 0e                	jmp    f0105ada <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105acc:	8b 10                	mov    (%eax),%edx
f0105ace:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105ad1:	89 08                	mov    %ecx,(%eax)
f0105ad3:	8b 02                	mov    (%edx),%eax
f0105ad5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105ada:	5d                   	pop    %ebp
f0105adb:	c3                   	ret    

f0105adc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105adc:	55                   	push   %ebp
f0105add:	89 e5                	mov    %esp,%ebp
f0105adf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105ae2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105ae5:	8b 10                	mov    (%eax),%edx
f0105ae7:	3b 50 04             	cmp    0x4(%eax),%edx
f0105aea:	73 08                	jae    f0105af4 <sprintputch+0x18>
		*b->buf++ = ch;
f0105aec:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105aef:	88 0a                	mov    %cl,(%edx)
f0105af1:	42                   	inc    %edx
f0105af2:	89 10                	mov    %edx,(%eax)
}
f0105af4:	5d                   	pop    %ebp
f0105af5:	c3                   	ret    

f0105af6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105af6:	55                   	push   %ebp
f0105af7:	89 e5                	mov    %esp,%ebp
f0105af9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105afc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105aff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b03:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b06:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b11:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b14:	89 04 24             	mov    %eax,(%esp)
f0105b17:	e8 02 00 00 00       	call   f0105b1e <vprintfmt>
	va_end(ap);
}
f0105b1c:	c9                   	leave  
f0105b1d:	c3                   	ret    

f0105b1e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105b1e:	55                   	push   %ebp
f0105b1f:	89 e5                	mov    %esp,%ebp
f0105b21:	57                   	push   %edi
f0105b22:	56                   	push   %esi
f0105b23:	53                   	push   %ebx
f0105b24:	83 ec 4c             	sub    $0x4c,%esp
f0105b27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b2a:	8b 75 10             	mov    0x10(%ebp),%esi
f0105b2d:	eb 12                	jmp    f0105b41 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105b2f:	85 c0                	test   %eax,%eax
f0105b31:	0f 84 6b 03 00 00    	je     f0105ea2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b3b:	89 04 24             	mov    %eax,(%esp)
f0105b3e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105b41:	0f b6 06             	movzbl (%esi),%eax
f0105b44:	46                   	inc    %esi
f0105b45:	83 f8 25             	cmp    $0x25,%eax
f0105b48:	75 e5                	jne    f0105b2f <vprintfmt+0x11>
f0105b4a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105b4e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105b55:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105b5a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105b61:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105b66:	eb 26                	jmp    f0105b8e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b68:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105b6b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105b6f:	eb 1d                	jmp    f0105b8e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b71:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105b74:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105b78:	eb 14                	jmp    f0105b8e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b7a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105b7d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105b84:	eb 08                	jmp    f0105b8e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105b86:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105b89:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b8e:	0f b6 06             	movzbl (%esi),%eax
f0105b91:	8d 56 01             	lea    0x1(%esi),%edx
f0105b94:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105b97:	8a 16                	mov    (%esi),%dl
f0105b99:	83 ea 23             	sub    $0x23,%edx
f0105b9c:	80 fa 55             	cmp    $0x55,%dl
f0105b9f:	0f 87 e1 02 00 00    	ja     f0105e86 <vprintfmt+0x368>
f0105ba5:	0f b6 d2             	movzbl %dl,%edx
f0105ba8:	ff 24 95 40 86 10 f0 	jmp    *-0xfef79c0(,%edx,4)
f0105baf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105bb2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105bb7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105bba:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105bbe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105bc1:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105bc4:	83 fa 09             	cmp    $0x9,%edx
f0105bc7:	77 2a                	ja     f0105bf3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105bc9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105bca:	eb eb                	jmp    f0105bb7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105bcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bcf:	8d 50 04             	lea    0x4(%eax),%edx
f0105bd2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bd5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bd7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105bda:	eb 17                	jmp    f0105bf3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105bdc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105be0:	78 98                	js     f0105b7a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105be2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105be5:	eb a7                	jmp    f0105b8e <vprintfmt+0x70>
f0105be7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105bea:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105bf1:	eb 9b                	jmp    f0105b8e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105bf3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bf7:	79 95                	jns    f0105b8e <vprintfmt+0x70>
f0105bf9:	eb 8b                	jmp    f0105b86 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105bfb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bfc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105bff:	eb 8d                	jmp    f0105b8e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105c01:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c04:	8d 50 04             	lea    0x4(%eax),%edx
f0105c07:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c0e:	8b 00                	mov    (%eax),%eax
f0105c10:	89 04 24             	mov    %eax,(%esp)
f0105c13:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c16:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105c19:	e9 23 ff ff ff       	jmp    f0105b41 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105c1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c21:	8d 50 04             	lea    0x4(%eax),%edx
f0105c24:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c27:	8b 00                	mov    (%eax),%eax
f0105c29:	85 c0                	test   %eax,%eax
f0105c2b:	79 02                	jns    f0105c2f <vprintfmt+0x111>
f0105c2d:	f7 d8                	neg    %eax
f0105c2f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105c31:	83 f8 09             	cmp    $0x9,%eax
f0105c34:	7f 0b                	jg     f0105c41 <vprintfmt+0x123>
f0105c36:	8b 04 85 a0 87 10 f0 	mov    -0xfef7860(,%eax,4),%eax
f0105c3d:	85 c0                	test   %eax,%eax
f0105c3f:	75 23                	jne    f0105c64 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105c41:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105c45:	c7 44 24 08 96 85 10 	movl   $0xf0108596,0x8(%esp)
f0105c4c:	f0 
f0105c4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c51:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c54:	89 04 24             	mov    %eax,(%esp)
f0105c57:	e8 9a fe ff ff       	call   f0105af6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c5c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105c5f:	e9 dd fe ff ff       	jmp    f0105b41 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105c64:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c68:	c7 44 24 08 39 7d 10 	movl   $0xf0107d39,0x8(%esp)
f0105c6f:	f0 
f0105c70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c74:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c77:	89 14 24             	mov    %edx,(%esp)
f0105c7a:	e8 77 fe ff ff       	call   f0105af6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105c82:	e9 ba fe ff ff       	jmp    f0105b41 <vprintfmt+0x23>
f0105c87:	89 f9                	mov    %edi,%ecx
f0105c89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105c8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c92:	8d 50 04             	lea    0x4(%eax),%edx
f0105c95:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c98:	8b 30                	mov    (%eax),%esi
f0105c9a:	85 f6                	test   %esi,%esi
f0105c9c:	75 05                	jne    f0105ca3 <vprintfmt+0x185>
				p = "(null)";
f0105c9e:	be 8f 85 10 f0       	mov    $0xf010858f,%esi
			if (width > 0 && padc != '-')
f0105ca3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105ca7:	0f 8e 84 00 00 00    	jle    f0105d31 <vprintfmt+0x213>
f0105cad:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105cb1:	74 7e                	je     f0105d31 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105cb3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105cb7:	89 34 24             	mov    %esi,(%esp)
f0105cba:	e8 53 03 00 00       	call   f0106012 <strnlen>
f0105cbf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105cc2:	29 c2                	sub    %eax,%edx
f0105cc4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105cc7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105ccb:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105cce:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105cd1:	89 de                	mov    %ebx,%esi
f0105cd3:	89 d3                	mov    %edx,%ebx
f0105cd5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105cd7:	eb 0b                	jmp    f0105ce4 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105cd9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105cdd:	89 3c 24             	mov    %edi,(%esp)
f0105ce0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ce3:	4b                   	dec    %ebx
f0105ce4:	85 db                	test   %ebx,%ebx
f0105ce6:	7f f1                	jg     f0105cd9 <vprintfmt+0x1bb>
f0105ce8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105ceb:	89 f3                	mov    %esi,%ebx
f0105ced:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105cf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cf3:	85 c0                	test   %eax,%eax
f0105cf5:	79 05                	jns    f0105cfc <vprintfmt+0x1de>
f0105cf7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105cff:	29 c2                	sub    %eax,%edx
f0105d01:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105d04:	eb 2b                	jmp    f0105d31 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105d06:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105d0a:	74 18                	je     f0105d24 <vprintfmt+0x206>
f0105d0c:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105d0f:	83 fa 5e             	cmp    $0x5e,%edx
f0105d12:	76 10                	jbe    f0105d24 <vprintfmt+0x206>
					putch('?', putdat);
f0105d14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d18:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105d1f:	ff 55 08             	call   *0x8(%ebp)
f0105d22:	eb 0a                	jmp    f0105d2e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105d24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d28:	89 04 24             	mov    %eax,(%esp)
f0105d2b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105d2e:	ff 4d e4             	decl   -0x1c(%ebp)
f0105d31:	0f be 06             	movsbl (%esi),%eax
f0105d34:	46                   	inc    %esi
f0105d35:	85 c0                	test   %eax,%eax
f0105d37:	74 21                	je     f0105d5a <vprintfmt+0x23c>
f0105d39:	85 ff                	test   %edi,%edi
f0105d3b:	78 c9                	js     f0105d06 <vprintfmt+0x1e8>
f0105d3d:	4f                   	dec    %edi
f0105d3e:	79 c6                	jns    f0105d06 <vprintfmt+0x1e8>
f0105d40:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d43:	89 de                	mov    %ebx,%esi
f0105d45:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105d48:	eb 18                	jmp    f0105d62 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105d4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105d4e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105d55:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105d57:	4b                   	dec    %ebx
f0105d58:	eb 08                	jmp    f0105d62 <vprintfmt+0x244>
f0105d5a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d5d:	89 de                	mov    %ebx,%esi
f0105d5f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105d62:	85 db                	test   %ebx,%ebx
f0105d64:	7f e4                	jg     f0105d4a <vprintfmt+0x22c>
f0105d66:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105d69:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d6b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105d6e:	e9 ce fd ff ff       	jmp    f0105b41 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105d73:	83 f9 01             	cmp    $0x1,%ecx
f0105d76:	7e 10                	jle    f0105d88 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0105d78:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d7b:	8d 50 08             	lea    0x8(%eax),%edx
f0105d7e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d81:	8b 30                	mov    (%eax),%esi
f0105d83:	8b 78 04             	mov    0x4(%eax),%edi
f0105d86:	eb 26                	jmp    f0105dae <vprintfmt+0x290>
	else if (lflag)
f0105d88:	85 c9                	test   %ecx,%ecx
f0105d8a:	74 12                	je     f0105d9e <vprintfmt+0x280>
		return va_arg(*ap, long);
f0105d8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d8f:	8d 50 04             	lea    0x4(%eax),%edx
f0105d92:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d95:	8b 30                	mov    (%eax),%esi
f0105d97:	89 f7                	mov    %esi,%edi
f0105d99:	c1 ff 1f             	sar    $0x1f,%edi
f0105d9c:	eb 10                	jmp    f0105dae <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0105d9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105da1:	8d 50 04             	lea    0x4(%eax),%edx
f0105da4:	89 55 14             	mov    %edx,0x14(%ebp)
f0105da7:	8b 30                	mov    (%eax),%esi
f0105da9:	89 f7                	mov    %esi,%edi
f0105dab:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105dae:	85 ff                	test   %edi,%edi
f0105db0:	78 0a                	js     f0105dbc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105db2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105db7:	e9 8c 00 00 00       	jmp    f0105e48 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105dbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105dc0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105dc7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105dca:	f7 de                	neg    %esi
f0105dcc:	83 d7 00             	adc    $0x0,%edi
f0105dcf:	f7 df                	neg    %edi
			}
			base = 10;
f0105dd1:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105dd6:	eb 70                	jmp    f0105e48 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105dd8:	89 ca                	mov    %ecx,%edx
f0105dda:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ddd:	e8 c0 fc ff ff       	call   f0105aa2 <getuint>
f0105de2:	89 c6                	mov    %eax,%esi
f0105de4:	89 d7                	mov    %edx,%edi
			base = 10;
f0105de6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105deb:	eb 5b                	jmp    f0105e48 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
f0105ded:	89 ca                	mov    %ecx,%edx
f0105def:	8d 45 14             	lea    0x14(%ebp),%eax
f0105df2:	e8 ab fc ff ff       	call   f0105aa2 <getuint>
f0105df7:	89 c6                	mov    %eax,%esi
f0105df9:	89 d7                	mov    %edx,%edi
                        base = 8;
f0105dfb:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
f0105e00:	eb 46                	jmp    f0105e48 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
f0105e02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e06:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105e0d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105e10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e14:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105e1b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105e1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e21:	8d 50 04             	lea    0x4(%eax),%edx
f0105e24:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105e27:	8b 30                	mov    (%eax),%esi
f0105e29:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105e2e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105e33:	eb 13                	jmp    f0105e48 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105e35:	89 ca                	mov    %ecx,%edx
f0105e37:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e3a:	e8 63 fc ff ff       	call   f0105aa2 <getuint>
f0105e3f:	89 c6                	mov    %eax,%esi
f0105e41:	89 d7                	mov    %edx,%edi
			base = 16;
f0105e43:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105e48:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105e4c:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105e50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105e53:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105e57:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e5b:	89 34 24             	mov    %esi,(%esp)
f0105e5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e62:	89 da                	mov    %ebx,%edx
f0105e64:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e67:	e8 6c fb ff ff       	call   f01059d8 <printnum>
			break;
f0105e6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105e6f:	e9 cd fc ff ff       	jmp    f0105b41 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105e74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e78:	89 04 24             	mov    %eax,(%esp)
f0105e7b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e7e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105e81:	e9 bb fc ff ff       	jmp    f0105b41 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105e86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e8a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105e91:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105e94:	eb 01                	jmp    f0105e97 <vprintfmt+0x379>
f0105e96:	4e                   	dec    %esi
f0105e97:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105e9b:	75 f9                	jne    f0105e96 <vprintfmt+0x378>
f0105e9d:	e9 9f fc ff ff       	jmp    f0105b41 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105ea2:	83 c4 4c             	add    $0x4c,%esp
f0105ea5:	5b                   	pop    %ebx
f0105ea6:	5e                   	pop    %esi
f0105ea7:	5f                   	pop    %edi
f0105ea8:	5d                   	pop    %ebp
f0105ea9:	c3                   	ret    

f0105eaa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105eaa:	55                   	push   %ebp
f0105eab:	89 e5                	mov    %esp,%ebp
f0105ead:	83 ec 28             	sub    $0x28,%esp
f0105eb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eb3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105eb9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105ebd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105ec0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105ec7:	85 c0                	test   %eax,%eax
f0105ec9:	74 30                	je     f0105efb <vsnprintf+0x51>
f0105ecb:	85 d2                	test   %edx,%edx
f0105ecd:	7e 33                	jle    f0105f02 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105ecf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ed2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ed6:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ed9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105edd:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ee4:	c7 04 24 dc 5a 10 f0 	movl   $0xf0105adc,(%esp)
f0105eeb:	e8 2e fc ff ff       	call   f0105b1e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105ef0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105ef3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105ef9:	eb 0c                	jmp    f0105f07 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105f00:	eb 05                	jmp    f0105f07 <vsnprintf+0x5d>
f0105f02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105f07:	c9                   	leave  
f0105f08:	c3                   	ret    

f0105f09 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105f09:	55                   	push   %ebp
f0105f0a:	89 e5                	mov    %esp,%ebp
f0105f0c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105f0f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f16:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f19:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f24:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f27:	89 04 24             	mov    %eax,(%esp)
f0105f2a:	e8 7b ff ff ff       	call   f0105eaa <vsnprintf>
	va_end(ap);

	return rc;
}
f0105f2f:	c9                   	leave  
f0105f30:	c3                   	ret    
f0105f31:	00 00                	add    %al,(%eax)
	...

f0105f34 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105f34:	55                   	push   %ebp
f0105f35:	89 e5                	mov    %esp,%ebp
f0105f37:	57                   	push   %edi
f0105f38:	56                   	push   %esi
f0105f39:	53                   	push   %ebx
f0105f3a:	83 ec 1c             	sub    $0x1c,%esp
f0105f3d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105f40:	85 c0                	test   %eax,%eax
f0105f42:	74 10                	je     f0105f54 <readline+0x20>
		cprintf("%s", prompt);
f0105f44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f48:	c7 04 24 39 7d 10 f0 	movl   $0xf0107d39,(%esp)
f0105f4f:	e8 c2 e0 ff ff       	call   f0104016 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105f54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105f5b:	e8 28 a8 ff ff       	call   f0100788 <iscons>
f0105f60:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105f62:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105f67:	e8 0b a8 ff ff       	call   f0100777 <getchar>
f0105f6c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105f6e:	85 c0                	test   %eax,%eax
f0105f70:	79 17                	jns    f0105f89 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105f72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f76:	c7 04 24 c8 87 10 f0 	movl   $0xf01087c8,(%esp)
f0105f7d:	e8 94 e0 ff ff       	call   f0104016 <cprintf>
			return NULL;
f0105f82:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f87:	eb 69                	jmp    f0105ff2 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105f89:	83 f8 08             	cmp    $0x8,%eax
f0105f8c:	74 05                	je     f0105f93 <readline+0x5f>
f0105f8e:	83 f8 7f             	cmp    $0x7f,%eax
f0105f91:	75 17                	jne    f0105faa <readline+0x76>
f0105f93:	85 f6                	test   %esi,%esi
f0105f95:	7e 13                	jle    f0105faa <readline+0x76>
			if (echoing)
f0105f97:	85 ff                	test   %edi,%edi
f0105f99:	74 0c                	je     f0105fa7 <readline+0x73>
				cputchar('\b');
f0105f9b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105fa2:	e8 c0 a7 ff ff       	call   f0100767 <cputchar>
			i--;
f0105fa7:	4e                   	dec    %esi
f0105fa8:	eb bd                	jmp    f0105f67 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105faa:	83 fb 1f             	cmp    $0x1f,%ebx
f0105fad:	7e 1d                	jle    f0105fcc <readline+0x98>
f0105faf:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105fb5:	7f 15                	jg     f0105fcc <readline+0x98>
			if (echoing)
f0105fb7:	85 ff                	test   %edi,%edi
f0105fb9:	74 08                	je     f0105fc3 <readline+0x8f>
				cputchar(c);
f0105fbb:	89 1c 24             	mov    %ebx,(%esp)
f0105fbe:	e8 a4 a7 ff ff       	call   f0100767 <cputchar>
			buf[i++] = c;
f0105fc3:	88 9e 80 1a 33 f0    	mov    %bl,-0xfcce580(%esi)
f0105fc9:	46                   	inc    %esi
f0105fca:	eb 9b                	jmp    f0105f67 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105fcc:	83 fb 0a             	cmp    $0xa,%ebx
f0105fcf:	74 05                	je     f0105fd6 <readline+0xa2>
f0105fd1:	83 fb 0d             	cmp    $0xd,%ebx
f0105fd4:	75 91                	jne    f0105f67 <readline+0x33>
			if (echoing)
f0105fd6:	85 ff                	test   %edi,%edi
f0105fd8:	74 0c                	je     f0105fe6 <readline+0xb2>
				cputchar('\n');
f0105fda:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105fe1:	e8 81 a7 ff ff       	call   f0100767 <cputchar>
			buf[i] = 0;
f0105fe6:	c6 86 80 1a 33 f0 00 	movb   $0x0,-0xfcce580(%esi)
			return buf;
f0105fed:	b8 80 1a 33 f0       	mov    $0xf0331a80,%eax
		}
	}
}
f0105ff2:	83 c4 1c             	add    $0x1c,%esp
f0105ff5:	5b                   	pop    %ebx
f0105ff6:	5e                   	pop    %esi
f0105ff7:	5f                   	pop    %edi
f0105ff8:	5d                   	pop    %ebp
f0105ff9:	c3                   	ret    
	...

f0105ffc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105ffc:	55                   	push   %ebp
f0105ffd:	89 e5                	mov    %esp,%ebp
f0105fff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106002:	b8 00 00 00 00       	mov    $0x0,%eax
f0106007:	eb 01                	jmp    f010600a <strlen+0xe>
		n++;
f0106009:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010600a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010600e:	75 f9                	jne    f0106009 <strlen+0xd>
		n++;
	return n;
}
f0106010:	5d                   	pop    %ebp
f0106011:	c3                   	ret    

f0106012 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106012:	55                   	push   %ebp
f0106013:	89 e5                	mov    %esp,%ebp
f0106015:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0106018:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010601b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106020:	eb 01                	jmp    f0106023 <strnlen+0x11>
		n++;
f0106022:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106023:	39 d0                	cmp    %edx,%eax
f0106025:	74 06                	je     f010602d <strnlen+0x1b>
f0106027:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010602b:	75 f5                	jne    f0106022 <strnlen+0x10>
		n++;
	return n;
}
f010602d:	5d                   	pop    %ebp
f010602e:	c3                   	ret    

f010602f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010602f:	55                   	push   %ebp
f0106030:	89 e5                	mov    %esp,%ebp
f0106032:	53                   	push   %ebx
f0106033:	8b 45 08             	mov    0x8(%ebp),%eax
f0106036:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106039:	ba 00 00 00 00       	mov    $0x0,%edx
f010603e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0106041:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0106044:	42                   	inc    %edx
f0106045:	84 c9                	test   %cl,%cl
f0106047:	75 f5                	jne    f010603e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106049:	5b                   	pop    %ebx
f010604a:	5d                   	pop    %ebp
f010604b:	c3                   	ret    

f010604c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010604c:	55                   	push   %ebp
f010604d:	89 e5                	mov    %esp,%ebp
f010604f:	53                   	push   %ebx
f0106050:	83 ec 08             	sub    $0x8,%esp
f0106053:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106056:	89 1c 24             	mov    %ebx,(%esp)
f0106059:	e8 9e ff ff ff       	call   f0105ffc <strlen>
	strcpy(dst + len, src);
f010605e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106061:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106065:	01 d8                	add    %ebx,%eax
f0106067:	89 04 24             	mov    %eax,(%esp)
f010606a:	e8 c0 ff ff ff       	call   f010602f <strcpy>
	return dst;
}
f010606f:	89 d8                	mov    %ebx,%eax
f0106071:	83 c4 08             	add    $0x8,%esp
f0106074:	5b                   	pop    %ebx
f0106075:	5d                   	pop    %ebp
f0106076:	c3                   	ret    

f0106077 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106077:	55                   	push   %ebp
f0106078:	89 e5                	mov    %esp,%ebp
f010607a:	56                   	push   %esi
f010607b:	53                   	push   %ebx
f010607c:	8b 45 08             	mov    0x8(%ebp),%eax
f010607f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106082:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106085:	b9 00 00 00 00       	mov    $0x0,%ecx
f010608a:	eb 0c                	jmp    f0106098 <strncpy+0x21>
		*dst++ = *src;
f010608c:	8a 1a                	mov    (%edx),%bl
f010608e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106091:	80 3a 01             	cmpb   $0x1,(%edx)
f0106094:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106097:	41                   	inc    %ecx
f0106098:	39 f1                	cmp    %esi,%ecx
f010609a:	75 f0                	jne    f010608c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010609c:	5b                   	pop    %ebx
f010609d:	5e                   	pop    %esi
f010609e:	5d                   	pop    %ebp
f010609f:	c3                   	ret    

f01060a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01060a0:	55                   	push   %ebp
f01060a1:	89 e5                	mov    %esp,%ebp
f01060a3:	56                   	push   %esi
f01060a4:	53                   	push   %ebx
f01060a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01060a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01060ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01060ae:	85 d2                	test   %edx,%edx
f01060b0:	75 0a                	jne    f01060bc <strlcpy+0x1c>
f01060b2:	89 f0                	mov    %esi,%eax
f01060b4:	eb 1a                	jmp    f01060d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01060b6:	88 18                	mov    %bl,(%eax)
f01060b8:	40                   	inc    %eax
f01060b9:	41                   	inc    %ecx
f01060ba:	eb 02                	jmp    f01060be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01060bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f01060be:	4a                   	dec    %edx
f01060bf:	74 0a                	je     f01060cb <strlcpy+0x2b>
f01060c1:	8a 19                	mov    (%ecx),%bl
f01060c3:	84 db                	test   %bl,%bl
f01060c5:	75 ef                	jne    f01060b6 <strlcpy+0x16>
f01060c7:	89 c2                	mov    %eax,%edx
f01060c9:	eb 02                	jmp    f01060cd <strlcpy+0x2d>
f01060cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01060cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01060d0:	29 f0                	sub    %esi,%eax
}
f01060d2:	5b                   	pop    %ebx
f01060d3:	5e                   	pop    %esi
f01060d4:	5d                   	pop    %ebp
f01060d5:	c3                   	ret    

f01060d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01060d6:	55                   	push   %ebp
f01060d7:	89 e5                	mov    %esp,%ebp
f01060d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01060dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01060df:	eb 02                	jmp    f01060e3 <strcmp+0xd>
		p++, q++;
f01060e1:	41                   	inc    %ecx
f01060e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01060e3:	8a 01                	mov    (%ecx),%al
f01060e5:	84 c0                	test   %al,%al
f01060e7:	74 04                	je     f01060ed <strcmp+0x17>
f01060e9:	3a 02                	cmp    (%edx),%al
f01060eb:	74 f4                	je     f01060e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01060ed:	0f b6 c0             	movzbl %al,%eax
f01060f0:	0f b6 12             	movzbl (%edx),%edx
f01060f3:	29 d0                	sub    %edx,%eax
}
f01060f5:	5d                   	pop    %ebp
f01060f6:	c3                   	ret    

f01060f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01060f7:	55                   	push   %ebp
f01060f8:	89 e5                	mov    %esp,%ebp
f01060fa:	53                   	push   %ebx
f01060fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01060fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106101:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0106104:	eb 03                	jmp    f0106109 <strncmp+0x12>
		n--, p++, q++;
f0106106:	4a                   	dec    %edx
f0106107:	40                   	inc    %eax
f0106108:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106109:	85 d2                	test   %edx,%edx
f010610b:	74 14                	je     f0106121 <strncmp+0x2a>
f010610d:	8a 18                	mov    (%eax),%bl
f010610f:	84 db                	test   %bl,%bl
f0106111:	74 04                	je     f0106117 <strncmp+0x20>
f0106113:	3a 19                	cmp    (%ecx),%bl
f0106115:	74 ef                	je     f0106106 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106117:	0f b6 00             	movzbl (%eax),%eax
f010611a:	0f b6 11             	movzbl (%ecx),%edx
f010611d:	29 d0                	sub    %edx,%eax
f010611f:	eb 05                	jmp    f0106126 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106121:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106126:	5b                   	pop    %ebx
f0106127:	5d                   	pop    %ebp
f0106128:	c3                   	ret    

f0106129 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106129:	55                   	push   %ebp
f010612a:	89 e5                	mov    %esp,%ebp
f010612c:	8b 45 08             	mov    0x8(%ebp),%eax
f010612f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0106132:	eb 05                	jmp    f0106139 <strchr+0x10>
		if (*s == c)
f0106134:	38 ca                	cmp    %cl,%dl
f0106136:	74 0c                	je     f0106144 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106138:	40                   	inc    %eax
f0106139:	8a 10                	mov    (%eax),%dl
f010613b:	84 d2                	test   %dl,%dl
f010613d:	75 f5                	jne    f0106134 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f010613f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106144:	5d                   	pop    %ebp
f0106145:	c3                   	ret    

f0106146 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106146:	55                   	push   %ebp
f0106147:	89 e5                	mov    %esp,%ebp
f0106149:	8b 45 08             	mov    0x8(%ebp),%eax
f010614c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010614f:	eb 05                	jmp    f0106156 <strfind+0x10>
		if (*s == c)
f0106151:	38 ca                	cmp    %cl,%dl
f0106153:	74 07                	je     f010615c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106155:	40                   	inc    %eax
f0106156:	8a 10                	mov    (%eax),%dl
f0106158:	84 d2                	test   %dl,%dl
f010615a:	75 f5                	jne    f0106151 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f010615c:	5d                   	pop    %ebp
f010615d:	c3                   	ret    

f010615e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010615e:	55                   	push   %ebp
f010615f:	89 e5                	mov    %esp,%ebp
f0106161:	57                   	push   %edi
f0106162:	56                   	push   %esi
f0106163:	53                   	push   %ebx
f0106164:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106167:	8b 45 0c             	mov    0xc(%ebp),%eax
f010616a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010616d:	85 c9                	test   %ecx,%ecx
f010616f:	74 30                	je     f01061a1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106171:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106177:	75 25                	jne    f010619e <memset+0x40>
f0106179:	f6 c1 03             	test   $0x3,%cl
f010617c:	75 20                	jne    f010619e <memset+0x40>
		c &= 0xFF;
f010617e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106181:	89 d3                	mov    %edx,%ebx
f0106183:	c1 e3 08             	shl    $0x8,%ebx
f0106186:	89 d6                	mov    %edx,%esi
f0106188:	c1 e6 18             	shl    $0x18,%esi
f010618b:	89 d0                	mov    %edx,%eax
f010618d:	c1 e0 10             	shl    $0x10,%eax
f0106190:	09 f0                	or     %esi,%eax
f0106192:	09 d0                	or     %edx,%eax
f0106194:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106196:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106199:	fc                   	cld    
f010619a:	f3 ab                	rep stos %eax,%es:(%edi)
f010619c:	eb 03                	jmp    f01061a1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010619e:	fc                   	cld    
f010619f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01061a1:	89 f8                	mov    %edi,%eax
f01061a3:	5b                   	pop    %ebx
f01061a4:	5e                   	pop    %esi
f01061a5:	5f                   	pop    %edi
f01061a6:	5d                   	pop    %ebp
f01061a7:	c3                   	ret    

f01061a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01061a8:	55                   	push   %ebp
f01061a9:	89 e5                	mov    %esp,%ebp
f01061ab:	57                   	push   %edi
f01061ac:	56                   	push   %esi
f01061ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01061b0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01061b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01061b6:	39 c6                	cmp    %eax,%esi
f01061b8:	73 34                	jae    f01061ee <memmove+0x46>
f01061ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01061bd:	39 d0                	cmp    %edx,%eax
f01061bf:	73 2d                	jae    f01061ee <memmove+0x46>
		s += n;
		d += n;
f01061c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01061c4:	f6 c2 03             	test   $0x3,%dl
f01061c7:	75 1b                	jne    f01061e4 <memmove+0x3c>
f01061c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01061cf:	75 13                	jne    f01061e4 <memmove+0x3c>
f01061d1:	f6 c1 03             	test   $0x3,%cl
f01061d4:	75 0e                	jne    f01061e4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01061d6:	83 ef 04             	sub    $0x4,%edi
f01061d9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01061dc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01061df:	fd                   	std    
f01061e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01061e2:	eb 07                	jmp    f01061eb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01061e4:	4f                   	dec    %edi
f01061e5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01061e8:	fd                   	std    
f01061e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01061eb:	fc                   	cld    
f01061ec:	eb 20                	jmp    f010620e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01061ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01061f4:	75 13                	jne    f0106209 <memmove+0x61>
f01061f6:	a8 03                	test   $0x3,%al
f01061f8:	75 0f                	jne    f0106209 <memmove+0x61>
f01061fa:	f6 c1 03             	test   $0x3,%cl
f01061fd:	75 0a                	jne    f0106209 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01061ff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106202:	89 c7                	mov    %eax,%edi
f0106204:	fc                   	cld    
f0106205:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106207:	eb 05                	jmp    f010620e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106209:	89 c7                	mov    %eax,%edi
f010620b:	fc                   	cld    
f010620c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010620e:	5e                   	pop    %esi
f010620f:	5f                   	pop    %edi
f0106210:	5d                   	pop    %ebp
f0106211:	c3                   	ret    

f0106212 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106212:	55                   	push   %ebp
f0106213:	89 e5                	mov    %esp,%ebp
f0106215:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106218:	8b 45 10             	mov    0x10(%ebp),%eax
f010621b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010621f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106222:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106226:	8b 45 08             	mov    0x8(%ebp),%eax
f0106229:	89 04 24             	mov    %eax,(%esp)
f010622c:	e8 77 ff ff ff       	call   f01061a8 <memmove>
}
f0106231:	c9                   	leave  
f0106232:	c3                   	ret    

f0106233 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106233:	55                   	push   %ebp
f0106234:	89 e5                	mov    %esp,%ebp
f0106236:	57                   	push   %edi
f0106237:	56                   	push   %esi
f0106238:	53                   	push   %ebx
f0106239:	8b 7d 08             	mov    0x8(%ebp),%edi
f010623c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010623f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106242:	ba 00 00 00 00       	mov    $0x0,%edx
f0106247:	eb 16                	jmp    f010625f <memcmp+0x2c>
		if (*s1 != *s2)
f0106249:	8a 04 17             	mov    (%edi,%edx,1),%al
f010624c:	42                   	inc    %edx
f010624d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0106251:	38 c8                	cmp    %cl,%al
f0106253:	74 0a                	je     f010625f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0106255:	0f b6 c0             	movzbl %al,%eax
f0106258:	0f b6 c9             	movzbl %cl,%ecx
f010625b:	29 c8                	sub    %ecx,%eax
f010625d:	eb 09                	jmp    f0106268 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010625f:	39 da                	cmp    %ebx,%edx
f0106261:	75 e6                	jne    f0106249 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106263:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106268:	5b                   	pop    %ebx
f0106269:	5e                   	pop    %esi
f010626a:	5f                   	pop    %edi
f010626b:	5d                   	pop    %ebp
f010626c:	c3                   	ret    

f010626d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010626d:	55                   	push   %ebp
f010626e:	89 e5                	mov    %esp,%ebp
f0106270:	8b 45 08             	mov    0x8(%ebp),%eax
f0106273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106276:	89 c2                	mov    %eax,%edx
f0106278:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010627b:	eb 05                	jmp    f0106282 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010627d:	38 08                	cmp    %cl,(%eax)
f010627f:	74 05                	je     f0106286 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106281:	40                   	inc    %eax
f0106282:	39 d0                	cmp    %edx,%eax
f0106284:	72 f7                	jb     f010627d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106286:	5d                   	pop    %ebp
f0106287:	c3                   	ret    

f0106288 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106288:	55                   	push   %ebp
f0106289:	89 e5                	mov    %esp,%ebp
f010628b:	57                   	push   %edi
f010628c:	56                   	push   %esi
f010628d:	53                   	push   %ebx
f010628e:	8b 55 08             	mov    0x8(%ebp),%edx
f0106291:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106294:	eb 01                	jmp    f0106297 <strtol+0xf>
		s++;
f0106296:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106297:	8a 02                	mov    (%edx),%al
f0106299:	3c 20                	cmp    $0x20,%al
f010629b:	74 f9                	je     f0106296 <strtol+0xe>
f010629d:	3c 09                	cmp    $0x9,%al
f010629f:	74 f5                	je     f0106296 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01062a1:	3c 2b                	cmp    $0x2b,%al
f01062a3:	75 08                	jne    f01062ad <strtol+0x25>
		s++;
f01062a5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01062a6:	bf 00 00 00 00       	mov    $0x0,%edi
f01062ab:	eb 13                	jmp    f01062c0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01062ad:	3c 2d                	cmp    $0x2d,%al
f01062af:	75 0a                	jne    f01062bb <strtol+0x33>
		s++, neg = 1;
f01062b1:	8d 52 01             	lea    0x1(%edx),%edx
f01062b4:	bf 01 00 00 00       	mov    $0x1,%edi
f01062b9:	eb 05                	jmp    f01062c0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01062bb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01062c0:	85 db                	test   %ebx,%ebx
f01062c2:	74 05                	je     f01062c9 <strtol+0x41>
f01062c4:	83 fb 10             	cmp    $0x10,%ebx
f01062c7:	75 28                	jne    f01062f1 <strtol+0x69>
f01062c9:	8a 02                	mov    (%edx),%al
f01062cb:	3c 30                	cmp    $0x30,%al
f01062cd:	75 10                	jne    f01062df <strtol+0x57>
f01062cf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01062d3:	75 0a                	jne    f01062df <strtol+0x57>
		s += 2, base = 16;
f01062d5:	83 c2 02             	add    $0x2,%edx
f01062d8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01062dd:	eb 12                	jmp    f01062f1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01062df:	85 db                	test   %ebx,%ebx
f01062e1:	75 0e                	jne    f01062f1 <strtol+0x69>
f01062e3:	3c 30                	cmp    $0x30,%al
f01062e5:	75 05                	jne    f01062ec <strtol+0x64>
		s++, base = 8;
f01062e7:	42                   	inc    %edx
f01062e8:	b3 08                	mov    $0x8,%bl
f01062ea:	eb 05                	jmp    f01062f1 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01062ec:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01062f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01062f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01062f8:	8a 0a                	mov    (%edx),%cl
f01062fa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01062fd:	80 fb 09             	cmp    $0x9,%bl
f0106300:	77 08                	ja     f010630a <strtol+0x82>
			dig = *s - '0';
f0106302:	0f be c9             	movsbl %cl,%ecx
f0106305:	83 e9 30             	sub    $0x30,%ecx
f0106308:	eb 1e                	jmp    f0106328 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010630a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010630d:	80 fb 19             	cmp    $0x19,%bl
f0106310:	77 08                	ja     f010631a <strtol+0x92>
			dig = *s - 'a' + 10;
f0106312:	0f be c9             	movsbl %cl,%ecx
f0106315:	83 e9 57             	sub    $0x57,%ecx
f0106318:	eb 0e                	jmp    f0106328 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010631a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010631d:	80 fb 19             	cmp    $0x19,%bl
f0106320:	77 12                	ja     f0106334 <strtol+0xac>
			dig = *s - 'A' + 10;
f0106322:	0f be c9             	movsbl %cl,%ecx
f0106325:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106328:	39 f1                	cmp    %esi,%ecx
f010632a:	7d 0c                	jge    f0106338 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f010632c:	42                   	inc    %edx
f010632d:	0f af c6             	imul   %esi,%eax
f0106330:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0106332:	eb c4                	jmp    f01062f8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106334:	89 c1                	mov    %eax,%ecx
f0106336:	eb 02                	jmp    f010633a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106338:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010633a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010633e:	74 05                	je     f0106345 <strtol+0xbd>
		*endptr = (char *) s;
f0106340:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106343:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106345:	85 ff                	test   %edi,%edi
f0106347:	74 04                	je     f010634d <strtol+0xc5>
f0106349:	89 c8                	mov    %ecx,%eax
f010634b:	f7 d8                	neg    %eax
}
f010634d:	5b                   	pop    %ebx
f010634e:	5e                   	pop    %esi
f010634f:	5f                   	pop    %edi
f0106350:	5d                   	pop    %ebp
f0106351:	c3                   	ret    
	...

f0106354 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106354:	fa                   	cli    

	xorw    %ax, %ax
f0106355:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106357:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106359:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010635b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010635d:	0f 01 16             	lgdtl  (%esi)
f0106360:	74 70                	je     f01063d2 <sum+0x2>
	movl    %cr0, %eax
f0106362:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106365:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106369:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010636c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106372:	08 00                	or     %al,(%eax)

f0106374 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106374:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106378:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010637a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010637c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010637e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106382:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106384:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106386:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f010638b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010638e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106391:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106396:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106399:	8b 25 84 1e 33 f0    	mov    0xf0331e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010639f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01063a4:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01063a9:	ff d0                	call   *%eax

f01063ab <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01063ab:	eb fe                	jmp    f01063ab <spin>
f01063ad:	8d 76 00             	lea    0x0(%esi),%esi

f01063b0 <gdt>:
	...
f01063b8:	ff                   	(bad)  
f01063b9:	ff 00                	incl   (%eax)
f01063bb:	00 00                	add    %al,(%eax)
f01063bd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01063c4:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01063c8 <gdtdesc>:
f01063c8:	17                   	pop    %ss
f01063c9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01063ce <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01063ce:	90                   	nop
	...

f01063d0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01063d0:	55                   	push   %ebp
f01063d1:	89 e5                	mov    %esp,%ebp
f01063d3:	56                   	push   %esi
f01063d4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f01063d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f01063da:	b9 00 00 00 00       	mov    $0x0,%ecx
f01063df:	eb 07                	jmp    f01063e8 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f01063e1:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01063e5:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063e7:	41                   	inc    %ecx
f01063e8:	39 d1                	cmp    %edx,%ecx
f01063ea:	7c f5                	jl     f01063e1 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01063ec:	88 d8                	mov    %bl,%al
f01063ee:	5b                   	pop    %ebx
f01063ef:	5e                   	pop    %esi
f01063f0:	5d                   	pop    %ebp
f01063f1:	c3                   	ret    

f01063f2 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01063f2:	55                   	push   %ebp
f01063f3:	89 e5                	mov    %esp,%ebp
f01063f5:	56                   	push   %esi
f01063f6:	53                   	push   %ebx
f01063f7:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063fa:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f0106400:	89 c3                	mov    %eax,%ebx
f0106402:	c1 eb 0c             	shr    $0xc,%ebx
f0106405:	39 cb                	cmp    %ecx,%ebx
f0106407:	72 20                	jb     f0106429 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106409:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010640d:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0106414:	f0 
f0106415:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010641c:	00 
f010641d:	c7 04 24 65 89 10 f0 	movl   $0xf0108965,(%esp)
f0106424:	e8 17 9c ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106429:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010642c:	89 f2                	mov    %esi,%edx
f010642e:	c1 ea 0c             	shr    $0xc,%edx
f0106431:	39 d1                	cmp    %edx,%ecx
f0106433:	77 20                	ja     f0106455 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106435:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106439:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0106440:	f0 
f0106441:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106448:	00 
f0106449:	c7 04 24 65 89 10 f0 	movl   $0xf0108965,(%esp)
f0106450:	e8 eb 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106455:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010645b:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106461:	eb 2f                	jmp    f0106492 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106463:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010646a:	00 
f010646b:	c7 44 24 04 75 89 10 	movl   $0xf0108975,0x4(%esp)
f0106472:	f0 
f0106473:	89 1c 24             	mov    %ebx,(%esp)
f0106476:	e8 b8 fd ff ff       	call   f0106233 <memcmp>
f010647b:	85 c0                	test   %eax,%eax
f010647d:	75 10                	jne    f010648f <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f010647f:	ba 10 00 00 00       	mov    $0x10,%edx
f0106484:	89 d8                	mov    %ebx,%eax
f0106486:	e8 45 ff ff ff       	call   f01063d0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010648b:	84 c0                	test   %al,%al
f010648d:	74 0c                	je     f010649b <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010648f:	83 c3 10             	add    $0x10,%ebx
f0106492:	39 f3                	cmp    %esi,%ebx
f0106494:	72 cd                	jb     f0106463 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106496:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010649b:	89 d8                	mov    %ebx,%eax
f010649d:	83 c4 10             	add    $0x10,%esp
f01064a0:	5b                   	pop    %ebx
f01064a1:	5e                   	pop    %esi
f01064a2:	5d                   	pop    %ebp
f01064a3:	c3                   	ret    

f01064a4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01064a4:	55                   	push   %ebp
f01064a5:	89 e5                	mov    %esp,%ebp
f01064a7:	57                   	push   %edi
f01064a8:	56                   	push   %esi
f01064a9:	53                   	push   %ebx
f01064aa:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01064ad:	c7 05 c0 23 33 f0 20 	movl   $0xf0332020,0xf03323c0
f01064b4:	20 33 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01064b7:	83 3d 88 1e 33 f0 00 	cmpl   $0x0,0xf0331e88
f01064be:	75 24                	jne    f01064e4 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064c0:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01064c7:	00 
f01064c8:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f01064cf:	f0 
f01064d0:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01064d7:	00 
f01064d8:	c7 04 24 65 89 10 f0 	movl   $0xf0108965,(%esp)
f01064df:	e8 5c 9b ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01064e4:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01064eb:	85 c0                	test   %eax,%eax
f01064ed:	74 16                	je     f0106505 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01064ef:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01064f2:	ba 00 04 00 00       	mov    $0x400,%edx
f01064f7:	e8 f6 fe ff ff       	call   f01063f2 <mpsearch1>
f01064fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064ff:	85 c0                	test   %eax,%eax
f0106501:	75 3c                	jne    f010653f <mp_init+0x9b>
f0106503:	eb 20                	jmp    f0106525 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106505:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010650c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010650f:	2d 00 04 00 00       	sub    $0x400,%eax
f0106514:	ba 00 04 00 00       	mov    $0x400,%edx
f0106519:	e8 d4 fe ff ff       	call   f01063f2 <mpsearch1>
f010651e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106521:	85 c0                	test   %eax,%eax
f0106523:	75 1a                	jne    f010653f <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106525:	ba 00 00 01 00       	mov    $0x10000,%edx
f010652a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010652f:	e8 be fe ff ff       	call   f01063f2 <mpsearch1>
f0106534:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106537:	85 c0                	test   %eax,%eax
f0106539:	0f 84 2c 02 00 00    	je     f010676b <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010653f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106542:	8b 58 04             	mov    0x4(%eax),%ebx
f0106545:	85 db                	test   %ebx,%ebx
f0106547:	74 06                	je     f010654f <mp_init+0xab>
f0106549:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010654d:	74 11                	je     f0106560 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010654f:	c7 04 24 d8 87 10 f0 	movl   $0xf01087d8,(%esp)
f0106556:	e8 bb da ff ff       	call   f0104016 <cprintf>
f010655b:	e9 0b 02 00 00       	jmp    f010676b <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106560:	89 d8                	mov    %ebx,%eax
f0106562:	c1 e8 0c             	shr    $0xc,%eax
f0106565:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f010656b:	72 20                	jb     f010658d <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010656d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106571:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0106578:	f0 
f0106579:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106580:	00 
f0106581:	c7 04 24 65 89 10 f0 	movl   $0xf0108965,(%esp)
f0106588:	e8 b3 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010658d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106593:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010659a:	00 
f010659b:	c7 44 24 04 7a 89 10 	movl   $0xf010897a,0x4(%esp)
f01065a2:	f0 
f01065a3:	89 1c 24             	mov    %ebx,(%esp)
f01065a6:	e8 88 fc ff ff       	call   f0106233 <memcmp>
f01065ab:	85 c0                	test   %eax,%eax
f01065ad:	74 11                	je     f01065c0 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01065af:	c7 04 24 08 88 10 f0 	movl   $0xf0108808,(%esp)
f01065b6:	e8 5b da ff ff       	call   f0104016 <cprintf>
f01065bb:	e9 ab 01 00 00       	jmp    f010676b <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01065c0:	66 8b 73 04          	mov    0x4(%ebx),%si
f01065c4:	0f b7 d6             	movzwl %si,%edx
f01065c7:	89 d8                	mov    %ebx,%eax
f01065c9:	e8 02 fe ff ff       	call   f01063d0 <sum>
f01065ce:	84 c0                	test   %al,%al
f01065d0:	74 11                	je     f01065e3 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f01065d2:	c7 04 24 3c 88 10 f0 	movl   $0xf010883c,(%esp)
f01065d9:	e8 38 da ff ff       	call   f0104016 <cprintf>
f01065de:	e9 88 01 00 00       	jmp    f010676b <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01065e3:	8a 43 06             	mov    0x6(%ebx),%al
f01065e6:	3c 01                	cmp    $0x1,%al
f01065e8:	74 1c                	je     f0106606 <mp_init+0x162>
f01065ea:	3c 04                	cmp    $0x4,%al
f01065ec:	74 18                	je     f0106606 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01065ee:	0f b6 c0             	movzbl %al,%eax
f01065f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065f5:	c7 04 24 60 88 10 f0 	movl   $0xf0108860,(%esp)
f01065fc:	e8 15 da ff ff       	call   f0104016 <cprintf>
f0106601:	e9 65 01 00 00       	jmp    f010676b <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106606:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f010660a:	0f b7 c6             	movzwl %si,%eax
f010660d:	01 d8                	add    %ebx,%eax
f010660f:	e8 bc fd ff ff       	call   f01063d0 <sum>
f0106614:	02 43 2a             	add    0x2a(%ebx),%al
f0106617:	84 c0                	test   %al,%al
f0106619:	74 11                	je     f010662c <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010661b:	c7 04 24 80 88 10 f0 	movl   $0xf0108880,(%esp)
f0106622:	e8 ef d9 ff ff       	call   f0104016 <cprintf>
f0106627:	e9 3f 01 00 00       	jmp    f010676b <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010662c:	85 db                	test   %ebx,%ebx
f010662e:	0f 84 37 01 00 00    	je     f010676b <mp_init+0x2c7>
		return;
	ismp = 1;
f0106634:	c7 05 00 20 33 f0 01 	movl   $0x1,0xf0332000
f010663b:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010663e:	8b 43 24             	mov    0x24(%ebx),%eax
f0106641:	a3 00 30 37 f0       	mov    %eax,0xf0373000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106646:	8d 73 2c             	lea    0x2c(%ebx),%esi
f0106649:	bf 00 00 00 00       	mov    $0x0,%edi
f010664e:	e9 94 00 00 00       	jmp    f01066e7 <mp_init+0x243>
		switch (*p) {
f0106653:	8a 06                	mov    (%esi),%al
f0106655:	84 c0                	test   %al,%al
f0106657:	74 06                	je     f010665f <mp_init+0x1bb>
f0106659:	3c 04                	cmp    $0x4,%al
f010665b:	77 68                	ja     f01066c5 <mp_init+0x221>
f010665d:	eb 61                	jmp    f01066c0 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010665f:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106663:	74 1d                	je     f0106682 <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f0106665:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f010666a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106671:	29 c2                	sub    %eax,%edx
f0106673:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106676:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f010667d:	a3 c0 23 33 f0       	mov    %eax,0xf03323c0
			if (ncpu < NCPU) {
f0106682:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f0106687:	83 f8 07             	cmp    $0x7,%eax
f010668a:	7f 1b                	jg     f01066a7 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f010668c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106693:	29 c2                	sub    %eax,%edx
f0106695:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106698:	88 04 95 20 20 33 f0 	mov    %al,-0xfccdfe0(,%edx,4)
				ncpu++;
f010669f:	40                   	inc    %eax
f01066a0:	a3 c4 23 33 f0       	mov    %eax,0xf03323c4
f01066a5:	eb 14                	jmp    f01066bb <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01066a7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01066ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066af:	c7 04 24 b0 88 10 f0 	movl   $0xf01088b0,(%esp)
f01066b6:	e8 5b d9 ff ff       	call   f0104016 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01066bb:	83 c6 14             	add    $0x14,%esi
			continue;
f01066be:	eb 26                	jmp    f01066e6 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01066c0:	83 c6 08             	add    $0x8,%esi
			continue;
f01066c3:	eb 21                	jmp    f01066e6 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01066c5:	0f b6 c0             	movzbl %al,%eax
f01066c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066cc:	c7 04 24 d8 88 10 f0 	movl   $0xf01088d8,(%esp)
f01066d3:	e8 3e d9 ff ff       	call   f0104016 <cprintf>
			ismp = 0;
f01066d8:	c7 05 00 20 33 f0 00 	movl   $0x0,0xf0332000
f01066df:	00 00 00 
			i = conf->entry;
f01066e2:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01066e6:	47                   	inc    %edi
f01066e7:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01066eb:	39 c7                	cmp    %eax,%edi
f01066ed:	0f 82 60 ff ff ff    	jb     f0106653 <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01066f3:	a1 c0 23 33 f0       	mov    0xf03323c0,%eax
f01066f8:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01066ff:	83 3d 00 20 33 f0 00 	cmpl   $0x0,0xf0332000
f0106706:	75 22                	jne    f010672a <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106708:	c7 05 c4 23 33 f0 01 	movl   $0x1,0xf03323c4
f010670f:	00 00 00 
		lapicaddr = 0;
f0106712:	c7 05 00 30 37 f0 00 	movl   $0x0,0xf0373000
f0106719:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010671c:	c7 04 24 f8 88 10 f0 	movl   $0xf01088f8,(%esp)
f0106723:	e8 ee d8 ff ff       	call   f0104016 <cprintf>
		return;
f0106728:	eb 41                	jmp    f010676b <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010672a:	8b 15 c4 23 33 f0    	mov    0xf03323c4,%edx
f0106730:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106734:	0f b6 00             	movzbl (%eax),%eax
f0106737:	89 44 24 04          	mov    %eax,0x4(%esp)
f010673b:	c7 04 24 7f 89 10 f0 	movl   $0xf010897f,(%esp)
f0106742:	e8 cf d8 ff ff       	call   f0104016 <cprintf>

	if (mp->imcrp) {
f0106747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010674a:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010674e:	74 1b                	je     f010676b <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106750:	c7 04 24 24 89 10 f0 	movl   $0xf0108924,(%esp)
f0106757:	e8 ba d8 ff ff       	call   f0104016 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010675c:	ba 22 00 00 00       	mov    $0x22,%edx
f0106761:	b0 70                	mov    $0x70,%al
f0106763:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106764:	b2 23                	mov    $0x23,%dl
f0106766:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106767:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010676a:	ee                   	out    %al,(%dx)
	}
}
f010676b:	83 c4 2c             	add    $0x2c,%esp
f010676e:	5b                   	pop    %ebx
f010676f:	5e                   	pop    %esi
f0106770:	5f                   	pop    %edi
f0106771:	5d                   	pop    %ebp
f0106772:	c3                   	ret    
	...

f0106774 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106774:	55                   	push   %ebp
f0106775:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106777:	c1 e0 02             	shl    $0x2,%eax
f010677a:	03 05 04 30 37 f0    	add    0xf0373004,%eax
f0106780:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106782:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f0106787:	8b 40 20             	mov    0x20(%eax),%eax
}
f010678a:	5d                   	pop    %ebp
f010678b:	c3                   	ret    

f010678c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010678c:	55                   	push   %ebp
f010678d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010678f:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f0106794:	85 c0                	test   %eax,%eax
f0106796:	74 08                	je     f01067a0 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106798:	8b 40 20             	mov    0x20(%eax),%eax
f010679b:	c1 e8 18             	shr    $0x18,%eax
f010679e:	eb 05                	jmp    f01067a5 <cpunum+0x19>
	return 0;
f01067a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01067a5:	5d                   	pop    %ebp
f01067a6:	c3                   	ret    

f01067a7 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01067a7:	55                   	push   %ebp
f01067a8:	89 e5                	mov    %esp,%ebp
f01067aa:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01067ad:	a1 00 30 37 f0       	mov    0xf0373000,%eax
f01067b2:	85 c0                	test   %eax,%eax
f01067b4:	0f 84 27 01 00 00    	je     f01068e1 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01067ba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01067c1:	00 
f01067c2:	89 04 24             	mov    %eax,(%esp)
f01067c5:	e8 ef ab ff ff       	call   f01013b9 <mmio_map_region>
f01067ca:	a3 04 30 37 f0       	mov    %eax,0xf0373004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01067cf:	ba 27 01 00 00       	mov    $0x127,%edx
f01067d4:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01067d9:	e8 96 ff ff ff       	call   f0106774 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01067de:	ba 0b 00 00 00       	mov    $0xb,%edx
f01067e3:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01067e8:	e8 87 ff ff ff       	call   f0106774 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01067ed:	ba 20 00 02 00       	mov    $0x20020,%edx
f01067f2:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01067f7:	e8 78 ff ff ff       	call   f0106774 <lapicw>
	lapicw(TICR, 10000000); 
f01067fc:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106801:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106806:	e8 69 ff ff ff       	call   f0106774 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010680b:	e8 7c ff ff ff       	call   f010678c <cpunum>
f0106810:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106817:	29 c2                	sub    %eax,%edx
f0106819:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010681c:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0106823:	39 05 c0 23 33 f0    	cmp    %eax,0xf03323c0
f0106829:	74 0f                	je     f010683a <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f010682b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106830:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106835:	e8 3a ff ff ff       	call   f0106774 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010683a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010683f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106844:	e8 2b ff ff ff       	call   f0106774 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106849:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f010684e:	8b 40 30             	mov    0x30(%eax),%eax
f0106851:	c1 e8 10             	shr    $0x10,%eax
f0106854:	3c 03                	cmp    $0x3,%al
f0106856:	76 0f                	jbe    f0106867 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f0106858:	ba 00 00 01 00       	mov    $0x10000,%edx
f010685d:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106862:	e8 0d ff ff ff       	call   f0106774 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106867:	ba 33 00 00 00       	mov    $0x33,%edx
f010686c:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106871:	e8 fe fe ff ff       	call   f0106774 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106876:	ba 00 00 00 00       	mov    $0x0,%edx
f010687b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106880:	e8 ef fe ff ff       	call   f0106774 <lapicw>
	lapicw(ESR, 0);
f0106885:	ba 00 00 00 00       	mov    $0x0,%edx
f010688a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010688f:	e8 e0 fe ff ff       	call   f0106774 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106894:	ba 00 00 00 00       	mov    $0x0,%edx
f0106899:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010689e:	e8 d1 fe ff ff       	call   f0106774 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01068a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01068a8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068ad:	e8 c2 fe ff ff       	call   f0106774 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01068b2:	ba 00 85 08 00       	mov    $0x88500,%edx
f01068b7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068bc:	e8 b3 fe ff ff       	call   f0106774 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01068c1:	8b 15 04 30 37 f0    	mov    0xf0373004,%edx
f01068c7:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01068cd:	f6 c4 10             	test   $0x10,%ah
f01068d0:	75 f5                	jne    f01068c7 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01068d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01068d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01068dc:	e8 93 fe ff ff       	call   f0106774 <lapicw>
}
f01068e1:	c9                   	leave  
f01068e2:	c3                   	ret    

f01068e3 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01068e3:	55                   	push   %ebp
f01068e4:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01068e6:	83 3d 04 30 37 f0 00 	cmpl   $0x0,0xf0373004
f01068ed:	74 0f                	je     f01068fe <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01068ef:	ba 00 00 00 00       	mov    $0x0,%edx
f01068f4:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01068f9:	e8 76 fe ff ff       	call   f0106774 <lapicw>
}
f01068fe:	5d                   	pop    %ebp
f01068ff:	c3                   	ret    

f0106900 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106900:	55                   	push   %ebp
f0106901:	89 e5                	mov    %esp,%ebp
f0106903:	56                   	push   %esi
f0106904:	53                   	push   %ebx
f0106905:	83 ec 10             	sub    $0x10,%esp
f0106908:	8b 75 0c             	mov    0xc(%ebp),%esi
f010690b:	8a 5d 08             	mov    0x8(%ebp),%bl
f010690e:	ba 70 00 00 00       	mov    $0x70,%edx
f0106913:	b0 0f                	mov    $0xf,%al
f0106915:	ee                   	out    %al,(%dx)
f0106916:	b2 71                	mov    $0x71,%dl
f0106918:	b0 0a                	mov    $0xa,%al
f010691a:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010691b:	83 3d 88 1e 33 f0 00 	cmpl   $0x0,0xf0331e88
f0106922:	75 24                	jne    f0106948 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106924:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010692b:	00 
f010692c:	c7 44 24 08 a8 6e 10 	movl   $0xf0106ea8,0x8(%esp)
f0106933:	f0 
f0106934:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010693b:	00 
f010693c:	c7 04 24 9c 89 10 f0 	movl   $0xf010899c,(%esp)
f0106943:	e8 f8 96 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106948:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010694f:	00 00 
	wrv[1] = addr >> 4;
f0106951:	89 f0                	mov    %esi,%eax
f0106953:	c1 e8 04             	shr    $0x4,%eax
f0106956:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010695c:	c1 e3 18             	shl    $0x18,%ebx
f010695f:	89 da                	mov    %ebx,%edx
f0106961:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106966:	e8 09 fe ff ff       	call   f0106774 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010696b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106970:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106975:	e8 fa fd ff ff       	call   f0106774 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010697a:	ba 00 85 00 00       	mov    $0x8500,%edx
f010697f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106984:	e8 eb fd ff ff       	call   f0106774 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106989:	c1 ee 0c             	shr    $0xc,%esi
f010698c:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106992:	89 da                	mov    %ebx,%edx
f0106994:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106999:	e8 d6 fd ff ff       	call   f0106774 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010699e:	89 f2                	mov    %esi,%edx
f01069a0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069a5:	e8 ca fd ff ff       	call   f0106774 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01069aa:	89 da                	mov    %ebx,%edx
f01069ac:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01069b1:	e8 be fd ff ff       	call   f0106774 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01069b6:	89 f2                	mov    %esi,%edx
f01069b8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069bd:	e8 b2 fd ff ff       	call   f0106774 <lapicw>
		microdelay(200);
	}
}
f01069c2:	83 c4 10             	add    $0x10,%esp
f01069c5:	5b                   	pop    %ebx
f01069c6:	5e                   	pop    %esi
f01069c7:	5d                   	pop    %ebp
f01069c8:	c3                   	ret    

f01069c9 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01069c9:	55                   	push   %ebp
f01069ca:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01069cc:	8b 55 08             	mov    0x8(%ebp),%edx
f01069cf:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01069d5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069da:	e8 95 fd ff ff       	call   f0106774 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01069df:	8b 15 04 30 37 f0    	mov    0xf0373004,%edx
f01069e5:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01069eb:	f6 c4 10             	test   $0x10,%ah
f01069ee:	75 f5                	jne    f01069e5 <lapic_ipi+0x1c>
		;
}
f01069f0:	5d                   	pop    %ebp
f01069f1:	c3                   	ret    
	...

f01069f4 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01069f4:	55                   	push   %ebp
f01069f5:	89 e5                	mov    %esp,%ebp
f01069f7:	53                   	push   %ebx
f01069f8:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01069fb:	83 38 00             	cmpl   $0x0,(%eax)
f01069fe:	74 25                	je     f0106a25 <holding+0x31>
f0106a00:	8b 58 08             	mov    0x8(%eax),%ebx
f0106a03:	e8 84 fd ff ff       	call   f010678c <cpunum>
f0106a08:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a0f:	29 c2                	sub    %eax,%edx
f0106a11:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a14:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106a1b:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106a1d:	0f 94 c0             	sete   %al
f0106a20:	0f b6 c0             	movzbl %al,%eax
f0106a23:	eb 05                	jmp    f0106a2a <holding+0x36>
f0106a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106a2a:	83 c4 04             	add    $0x4,%esp
f0106a2d:	5b                   	pop    %ebx
f0106a2e:	5d                   	pop    %ebp
f0106a2f:	c3                   	ret    

f0106a30 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106a30:	55                   	push   %ebp
f0106a31:	89 e5                	mov    %esp,%ebp
f0106a33:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106a36:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106a3f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106a42:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106a49:	5d                   	pop    %ebp
f0106a4a:	c3                   	ret    

f0106a4b <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106a4b:	55                   	push   %ebp
f0106a4c:	89 e5                	mov    %esp,%ebp
f0106a4e:	53                   	push   %ebx
f0106a4f:	83 ec 24             	sub    $0x24,%esp
f0106a52:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106a55:	89 d8                	mov    %ebx,%eax
f0106a57:	e8 98 ff ff ff       	call   f01069f4 <holding>
f0106a5c:	85 c0                	test   %eax,%eax
f0106a5e:	74 30                	je     f0106a90 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106a60:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a63:	e8 24 fd ff ff       	call   f010678c <cpunum>
f0106a68:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a70:	c7 44 24 08 ac 89 10 	movl   $0xf01089ac,0x8(%esp)
f0106a77:	f0 
f0106a78:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106a7f:	00 
f0106a80:	c7 04 24 10 8a 10 f0 	movl   $0xf0108a10,(%esp)
f0106a87:	e8 b4 95 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a8c:	f3 90                	pause  
f0106a8e:	eb 05                	jmp    f0106a95 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106a90:	ba 01 00 00 00       	mov    $0x1,%edx
f0106a95:	89 d0                	mov    %edx,%eax
f0106a97:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a9a:	85 c0                	test   %eax,%eax
f0106a9c:	75 ee                	jne    f0106a8c <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a9e:	e8 e9 fc ff ff       	call   f010678c <cpunum>
f0106aa3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106aaa:	29 c2                	sub    %eax,%edx
f0106aac:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106aaf:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0106ab6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106ab9:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106abc:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106abe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106ac3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106ac9:	76 10                	jbe    f0106adb <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106acb:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106ace:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106ad1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106ad3:	40                   	inc    %eax
f0106ad4:	83 f8 0a             	cmp    $0xa,%eax
f0106ad7:	75 ea                	jne    f0106ac3 <spin_lock+0x78>
f0106ad9:	eb 0d                	jmp    f0106ae8 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106adb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106ae2:	40                   	inc    %eax
f0106ae3:	83 f8 09             	cmp    $0x9,%eax
f0106ae6:	7e f3                	jle    f0106adb <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106ae8:	83 c4 24             	add    $0x24,%esp
f0106aeb:	5b                   	pop    %ebx
f0106aec:	5d                   	pop    %ebp
f0106aed:	c3                   	ret    

f0106aee <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106aee:	55                   	push   %ebp
f0106aef:	89 e5                	mov    %esp,%ebp
f0106af1:	57                   	push   %edi
f0106af2:	56                   	push   %esi
f0106af3:	53                   	push   %ebx
f0106af4:	83 ec 7c             	sub    $0x7c,%esp
f0106af7:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106afa:	89 d8                	mov    %ebx,%eax
f0106afc:	e8 f3 fe ff ff       	call   f01069f4 <holding>
f0106b01:	85 c0                	test   %eax,%eax
f0106b03:	0f 85 d3 00 00 00    	jne    f0106bdc <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106b09:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106b10:	00 
f0106b11:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106b14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b18:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106b1b:	89 34 24             	mov    %esi,(%esp)
f0106b1e:	e8 85 f6 ff ff       	call   f01061a8 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106b23:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106b26:	0f b6 38             	movzbl (%eax),%edi
f0106b29:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106b2c:	e8 5b fc ff ff       	call   f010678c <cpunum>
f0106b31:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106b35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b3d:	c7 04 24 d8 89 10 f0 	movl   $0xf01089d8,(%esp)
f0106b44:	e8 cd d4 ff ff       	call   f0104016 <cprintf>
f0106b49:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106b4b:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106b4e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106b51:	89 c7                	mov    %eax,%edi
f0106b53:	eb 63                	jmp    f0106bb8 <spin_unlock+0xca>
f0106b55:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106b59:	89 04 24             	mov    %eax,(%esp)
f0106b5c:	e8 08 eb ff ff       	call   f0105669 <debuginfo_eip>
f0106b61:	85 c0                	test   %eax,%eax
f0106b63:	78 39                	js     f0106b9e <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106b65:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106b67:	89 c2                	mov    %eax,%edx
f0106b69:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106b6c:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106b70:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106b73:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b77:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106b7a:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b7e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106b81:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b85:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106b88:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b90:	c7 04 24 20 8a 10 f0 	movl   $0xf0108a20,(%esp)
f0106b97:	e8 7a d4 ff ff       	call   f0104016 <cprintf>
f0106b9c:	eb 12                	jmp    f0106bb0 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106b9e:	8b 06                	mov    (%esi),%eax
f0106ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ba4:	c7 04 24 37 8a 10 f0 	movl   $0xf0108a37,(%esp)
f0106bab:	e8 66 d4 ff ff       	call   f0104016 <cprintf>
f0106bb0:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106bb3:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106bb6:	74 08                	je     f0106bc0 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106bb8:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106bba:	8b 03                	mov    (%ebx),%eax
f0106bbc:	85 c0                	test   %eax,%eax
f0106bbe:	75 95                	jne    f0106b55 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106bc0:	c7 44 24 08 3f 8a 10 	movl   $0xf0108a3f,0x8(%esp)
f0106bc7:	f0 
f0106bc8:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106bcf:	00 
f0106bd0:	c7 04 24 10 8a 10 f0 	movl   $0xf0108a10,(%esp)
f0106bd7:	e8 64 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106bdc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106be3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106bea:	b8 00 00 00 00       	mov    $0x0,%eax
f0106bef:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106bf2:	83 c4 7c             	add    $0x7c,%esp
f0106bf5:	5b                   	pop    %ebx
f0106bf6:	5e                   	pop    %esi
f0106bf7:	5f                   	pop    %edi
f0106bf8:	5d                   	pop    %ebp
f0106bf9:	c3                   	ret    
	...

f0106bfc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0106bfc:	55                   	push   %ebp
f0106bfd:	57                   	push   %edi
f0106bfe:	56                   	push   %esi
f0106bff:	83 ec 10             	sub    $0x10,%esp
f0106c02:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106c06:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106c0a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106c0e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0106c12:	89 cd                	mov    %ecx,%ebp
f0106c14:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106c18:	85 c0                	test   %eax,%eax
f0106c1a:	75 2c                	jne    f0106c48 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0106c1c:	39 f9                	cmp    %edi,%ecx
f0106c1e:	77 68                	ja     f0106c88 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106c20:	85 c9                	test   %ecx,%ecx
f0106c22:	75 0b                	jne    f0106c2f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106c24:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c29:	31 d2                	xor    %edx,%edx
f0106c2b:	f7 f1                	div    %ecx
f0106c2d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106c2f:	31 d2                	xor    %edx,%edx
f0106c31:	89 f8                	mov    %edi,%eax
f0106c33:	f7 f1                	div    %ecx
f0106c35:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106c37:	89 f0                	mov    %esi,%eax
f0106c39:	f7 f1                	div    %ecx
f0106c3b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106c3d:	89 f0                	mov    %esi,%eax
f0106c3f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106c41:	83 c4 10             	add    $0x10,%esp
f0106c44:	5e                   	pop    %esi
f0106c45:	5f                   	pop    %edi
f0106c46:	5d                   	pop    %ebp
f0106c47:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106c48:	39 f8                	cmp    %edi,%eax
f0106c4a:	77 2c                	ja     f0106c78 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106c4c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0106c4f:	83 f6 1f             	xor    $0x1f,%esi
f0106c52:	75 4c                	jne    f0106ca0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106c54:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106c56:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106c5b:	72 0a                	jb     f0106c67 <__udivdi3+0x6b>
f0106c5d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106c61:	0f 87 ad 00 00 00    	ja     f0106d14 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106c67:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106c6c:	89 f0                	mov    %esi,%eax
f0106c6e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106c70:	83 c4 10             	add    $0x10,%esp
f0106c73:	5e                   	pop    %esi
f0106c74:	5f                   	pop    %edi
f0106c75:	5d                   	pop    %ebp
f0106c76:	c3                   	ret    
f0106c77:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106c78:	31 ff                	xor    %edi,%edi
f0106c7a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106c7c:	89 f0                	mov    %esi,%eax
f0106c7e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106c80:	83 c4 10             	add    $0x10,%esp
f0106c83:	5e                   	pop    %esi
f0106c84:	5f                   	pop    %edi
f0106c85:	5d                   	pop    %ebp
f0106c86:	c3                   	ret    
f0106c87:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106c88:	89 fa                	mov    %edi,%edx
f0106c8a:	89 f0                	mov    %esi,%eax
f0106c8c:	f7 f1                	div    %ecx
f0106c8e:	89 c6                	mov    %eax,%esi
f0106c90:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106c92:	89 f0                	mov    %esi,%eax
f0106c94:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106c96:	83 c4 10             	add    $0x10,%esp
f0106c99:	5e                   	pop    %esi
f0106c9a:	5f                   	pop    %edi
f0106c9b:	5d                   	pop    %ebp
f0106c9c:	c3                   	ret    
f0106c9d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106ca0:	89 f1                	mov    %esi,%ecx
f0106ca2:	d3 e0                	shl    %cl,%eax
f0106ca4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106ca8:	b8 20 00 00 00       	mov    $0x20,%eax
f0106cad:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106caf:	89 ea                	mov    %ebp,%edx
f0106cb1:	88 c1                	mov    %al,%cl
f0106cb3:	d3 ea                	shr    %cl,%edx
f0106cb5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106cb9:	09 ca                	or     %ecx,%edx
f0106cbb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0106cbf:	89 f1                	mov    %esi,%ecx
f0106cc1:	d3 e5                	shl    %cl,%ebp
f0106cc3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0106cc7:	89 fd                	mov    %edi,%ebp
f0106cc9:	88 c1                	mov    %al,%cl
f0106ccb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0106ccd:	89 fa                	mov    %edi,%edx
f0106ccf:	89 f1                	mov    %esi,%ecx
f0106cd1:	d3 e2                	shl    %cl,%edx
f0106cd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106cd7:	88 c1                	mov    %al,%cl
f0106cd9:	d3 ef                	shr    %cl,%edi
f0106cdb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106cdd:	89 f8                	mov    %edi,%eax
f0106cdf:	89 ea                	mov    %ebp,%edx
f0106ce1:	f7 74 24 08          	divl   0x8(%esp)
f0106ce5:	89 d1                	mov    %edx,%ecx
f0106ce7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f0106ce9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106ced:	39 d1                	cmp    %edx,%ecx
f0106cef:	72 17                	jb     f0106d08 <__udivdi3+0x10c>
f0106cf1:	74 09                	je     f0106cfc <__udivdi3+0x100>
f0106cf3:	89 fe                	mov    %edi,%esi
f0106cf5:	31 ff                	xor    %edi,%edi
f0106cf7:	e9 41 ff ff ff       	jmp    f0106c3d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106cfc:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106d00:	89 f1                	mov    %esi,%ecx
f0106d02:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106d04:	39 c2                	cmp    %eax,%edx
f0106d06:	73 eb                	jae    f0106cf3 <__udivdi3+0xf7>
		{
		  q0--;
f0106d08:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106d0b:	31 ff                	xor    %edi,%edi
f0106d0d:	e9 2b ff ff ff       	jmp    f0106c3d <__udivdi3+0x41>
f0106d12:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106d14:	31 f6                	xor    %esi,%esi
f0106d16:	e9 22 ff ff ff       	jmp    f0106c3d <__udivdi3+0x41>
	...

f0106d1c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106d1c:	55                   	push   %ebp
f0106d1d:	57                   	push   %edi
f0106d1e:	56                   	push   %esi
f0106d1f:	83 ec 20             	sub    $0x20,%esp
f0106d22:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106d26:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106d2a:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106d2e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0106d32:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106d36:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106d3a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0106d3c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106d3e:	85 ed                	test   %ebp,%ebp
f0106d40:	75 16                	jne    f0106d58 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0106d42:	39 f1                	cmp    %esi,%ecx
f0106d44:	0f 86 a6 00 00 00    	jbe    f0106df0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106d4a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106d4c:	89 d0                	mov    %edx,%eax
f0106d4e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d50:	83 c4 20             	add    $0x20,%esp
f0106d53:	5e                   	pop    %esi
f0106d54:	5f                   	pop    %edi
f0106d55:	5d                   	pop    %ebp
f0106d56:	c3                   	ret    
f0106d57:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106d58:	39 f5                	cmp    %esi,%ebp
f0106d5a:	0f 87 ac 00 00 00    	ja     f0106e0c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106d60:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0106d63:	83 f0 1f             	xor    $0x1f,%eax
f0106d66:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106d6a:	0f 84 a8 00 00 00    	je     f0106e18 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106d70:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d74:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106d76:	bf 20 00 00 00       	mov    $0x20,%edi
f0106d7b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106d7f:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d83:	89 f9                	mov    %edi,%ecx
f0106d85:	d3 e8                	shr    %cl,%eax
f0106d87:	09 e8                	or     %ebp,%eax
f0106d89:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0106d8d:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d91:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d95:	d3 e0                	shl    %cl,%eax
f0106d97:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106d9b:	89 f2                	mov    %esi,%edx
f0106d9d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106d9f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106da3:	d3 e0                	shl    %cl,%eax
f0106da5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106da9:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106dad:	89 f9                	mov    %edi,%ecx
f0106daf:	d3 e8                	shr    %cl,%eax
f0106db1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106db3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106db5:	89 f2                	mov    %esi,%edx
f0106db7:	f7 74 24 18          	divl   0x18(%esp)
f0106dbb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106dbd:	f7 64 24 0c          	mull   0xc(%esp)
f0106dc1:	89 c5                	mov    %eax,%ebp
f0106dc3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106dc5:	39 d6                	cmp    %edx,%esi
f0106dc7:	72 67                	jb     f0106e30 <__umoddi3+0x114>
f0106dc9:	74 75                	je     f0106e40 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0106dcb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106dcf:	29 e8                	sub    %ebp,%eax
f0106dd1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0106dd3:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106dd7:	d3 e8                	shr    %cl,%eax
f0106dd9:	89 f2                	mov    %esi,%edx
f0106ddb:	89 f9                	mov    %edi,%ecx
f0106ddd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0106ddf:	09 d0                	or     %edx,%eax
f0106de1:	89 f2                	mov    %esi,%edx
f0106de3:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106de7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106de9:	83 c4 20             	add    $0x20,%esp
f0106dec:	5e                   	pop    %esi
f0106ded:	5f                   	pop    %edi
f0106dee:	5d                   	pop    %ebp
f0106def:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106df0:	85 c9                	test   %ecx,%ecx
f0106df2:	75 0b                	jne    f0106dff <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106df4:	b8 01 00 00 00       	mov    $0x1,%eax
f0106df9:	31 d2                	xor    %edx,%edx
f0106dfb:	f7 f1                	div    %ecx
f0106dfd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106dff:	89 f0                	mov    %esi,%eax
f0106e01:	31 d2                	xor    %edx,%edx
f0106e03:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106e05:	89 f8                	mov    %edi,%eax
f0106e07:	e9 3e ff ff ff       	jmp    f0106d4a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0106e0c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106e0e:	83 c4 20             	add    $0x20,%esp
f0106e11:	5e                   	pop    %esi
f0106e12:	5f                   	pop    %edi
f0106e13:	5d                   	pop    %ebp
f0106e14:	c3                   	ret    
f0106e15:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106e18:	39 f5                	cmp    %esi,%ebp
f0106e1a:	72 04                	jb     f0106e20 <__umoddi3+0x104>
f0106e1c:	39 f9                	cmp    %edi,%ecx
f0106e1e:	77 06                	ja     f0106e26 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106e20:	89 f2                	mov    %esi,%edx
f0106e22:	29 cf                	sub    %ecx,%edi
f0106e24:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0106e26:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106e28:	83 c4 20             	add    $0x20,%esp
f0106e2b:	5e                   	pop    %esi
f0106e2c:	5f                   	pop    %edi
f0106e2d:	5d                   	pop    %ebp
f0106e2e:	c3                   	ret    
f0106e2f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106e30:	89 d1                	mov    %edx,%ecx
f0106e32:	89 c5                	mov    %eax,%ebp
f0106e34:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106e38:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106e3c:	eb 8d                	jmp    f0106dcb <__umoddi3+0xaf>
f0106e3e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106e40:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106e44:	72 ea                	jb     f0106e30 <__umoddi3+0x114>
f0106e46:	89 f1                	mov    %esi,%ecx
f0106e48:	eb 81                	jmp    f0106dcb <__umoddi3+0xaf>
