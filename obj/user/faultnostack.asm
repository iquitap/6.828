
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 a8 03 80 	movl   $0x8003a8,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 90 02 00 00       	call   8002de <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  80006a:	e8 e4 00 00 00       	call   800153 <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x39>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 3f 00 00 00       	call   800101 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800146:	e8 85 02 00 00       	call   8003d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	83 c4 2c             	add    $0x2c,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7e 28                	jle    8001dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8001d8:	e8 f3 01 00 00       	call   8003d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	83 c4 2c             	add    $0x2c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 28                	jle    800230 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800213:	00 
  800214:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80022b:	e8 a0 01 00 00       	call   8003d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	83 c4 2c             	add    $0x2c,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	89 df                	mov    %ebx,%edi
  800253:	89 de                	mov    %ebx,%esi
  800255:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800257:	85 c0                	test   %eax,%eax
  800259:	7e 28                	jle    800283 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800266:	00 
  800267:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  80027e:	e8 4d 01 00 00       	call   8003d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	83 c4 2c             	add    $0x2c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 08 00 00 00       	mov    $0x8,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  8002d1:	e8 fa 00 00 00       	call   8003d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d6:	83 c4 2c             	add    $0x2c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 28                	jle    800329 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800324:	e8 a7 00 00 00       	call   8003d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800337:	be 00 00 00 00       	mov    $0x0,%esi
  80033c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800341:	8b 7d 14             	mov    0x14(%ebp),%edi
  800344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	b8 0c 00 00 00       	mov    $0xc,%eax
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
  80036a:	89 cb                	mov    %ecx,%ebx
  80036c:	89 cf                	mov    %ecx,%edi
  80036e:	89 ce                	mov    %ecx,%esi
  800370:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 28                	jle    80039e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800381:	00 
  800382:	c7 44 24 08 8a 10 80 	movl   $0x80108a,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 a7 10 80 00 	movl   $0x8010a7,(%esp)
  800399:	e8 32 00 00 00       	call   8003d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039e:	83 c4 2c             	add    $0x2c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    
	...

008003a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003a9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8003ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003b0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl %esp,%ebx
  8003b3:	89 e3                	mov    %esp,%ebx
        movl 40(%esp), %eax
  8003b5:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl 48(%esp), %esp
  8003b9:	8b 64 24 30          	mov    0x30(%esp),%esp
        pushl %eax
  8003bd:	50                   	push   %eax
        
        // Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
        
        movl %ebx, %esp
  8003be:	89 dc                	mov    %ebx,%esp
        subl $4, 48(%esp)
  8003c0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
        popl %eax
  8003c5:	58                   	pop    %eax
        popl %eax
  8003c6:	58                   	pop    %eax
        popal
  8003c7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        add $4,%esp
  8003c8:	83 c4 04             	add    $0x4,%esp
        popfl
  8003cb:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8003cc:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret;
  8003cd:	c3                   	ret    
	...

008003d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	56                   	push   %esi
  8003d4:	53                   	push   %ebx
  8003d5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003db:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003e1:	e8 6d fd ff ff       	call   800153 <sys_getenvid>
  8003e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fc:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  800403:	e8 c0 00 00 00       	call   8004c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800408:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	e8 50 00 00 00       	call   800467 <vcprintf>
	cprintf("\n");
  800417:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  80041e:	e8 a5 00 00 00       	call   8004c8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800423:	cc                   	int3   
  800424:	eb fd                	jmp    800423 <_panic+0x53>
	...

00800428 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	53                   	push   %ebx
  80042c:	83 ec 14             	sub    $0x14,%esp
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800432:	8b 03                	mov    (%ebx),%eax
  800434:	8b 55 08             	mov    0x8(%ebp),%edx
  800437:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80043b:	40                   	inc    %eax
  80043c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80043e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800443:	75 19                	jne    80045e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800445:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80044c:	00 
  80044d:	8d 43 08             	lea    0x8(%ebx),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 6c fc ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  800458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80045e:	ff 43 04             	incl   0x4(%ebx)
}
  800461:	83 c4 14             	add    $0x14,%esp
  800464:	5b                   	pop    %ebx
  800465:	5d                   	pop    %ebp
  800466:	c3                   	ret    

00800467 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800470:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800477:	00 00 00 
	b.cnt = 0;
  80047a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800481:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800484:	8b 45 0c             	mov    0xc(%ebp),%eax
  800487:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800492:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049c:	c7 04 24 28 04 80 00 	movl   $0x800428,(%esp)
  8004a3:	e8 82 01 00 00       	call   80062a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	e8 04 fc ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  8004c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    

008004c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 87 ff ff ff       	call   800467 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    
	...

008004e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	57                   	push   %edi
  8004e8:	56                   	push   %esi
  8004e9:	53                   	push   %ebx
  8004ea:	83 ec 3c             	sub    $0x3c,%esp
  8004ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800501:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800504:	85 c0                	test   %eax,%eax
  800506:	75 08                	jne    800510 <printnum+0x2c>
  800508:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80050e:	77 57                	ja     800567 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800510:	89 74 24 10          	mov    %esi,0x10(%esp)
  800514:	4b                   	dec    %ebx
  800515:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800519:	8b 45 10             	mov    0x10(%ebp),%eax
  80051c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800520:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800524:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800528:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80052f:	00 
  800530:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053d:	e8 e2 08 00 00       	call   800e24 <__udivdi3>
  800542:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800546:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800551:	89 fa                	mov    %edi,%edx
  800553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800556:	e8 89 ff ff ff       	call   8004e4 <printnum>
  80055b:	eb 0f                	jmp    80056c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800567:	4b                   	dec    %ebx
  800568:	85 db                	test   %ebx,%ebx
  80056a:	7f f1                	jg     80055d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800570:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800574:	8b 45 10             	mov    0x10(%ebp),%eax
  800577:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800582:	00 
  800583:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800586:	89 04 24             	mov    %eax,(%esp)
  800589:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800590:	e8 af 09 00 00       	call   800f44 <__umoddi3>
  800595:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800599:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005a6:	83 c4 3c             	add    $0x3c,%esp
  8005a9:	5b                   	pop    %ebx
  8005aa:	5e                   	pop    %esi
  8005ab:	5f                   	pop    %edi
  8005ac:	5d                   	pop    %ebp
  8005ad:	c3                   	ret    

008005ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005b1:	83 fa 01             	cmp    $0x1,%edx
  8005b4:	7e 0e                	jle    8005c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005bb:	89 08                	mov    %ecx,(%eax)
  8005bd:	8b 02                	mov    (%edx),%eax
  8005bf:	8b 52 04             	mov    0x4(%edx),%edx
  8005c2:	eb 22                	jmp    8005e6 <getuint+0x38>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 10                	je     8005d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 02                	mov    (%edx),%eax
  8005d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d6:	eb 0e                	jmp    8005e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005dd:	89 08                	mov    %ecx,(%eax)
  8005df:	8b 02                	mov    (%edx),%eax
  8005e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e6:	5d                   	pop    %ebp
  8005e7:	c3                   	ret    

008005e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ee:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f6:	73 08                	jae    800600 <sprintputch+0x18>
		*b->buf++ = ch;
  8005f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005fb:	88 0a                	mov    %cl,(%edx)
  8005fd:	42                   	inc    %edx
  8005fe:	89 10                	mov    %edx,(%eax)
}
  800600:	5d                   	pop    %ebp
  800601:	c3                   	ret    

00800602 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800602:	55                   	push   %ebp
  800603:	89 e5                	mov    %esp,%ebp
  800605:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800608:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80060b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060f:	8b 45 10             	mov    0x10(%ebp),%eax
  800612:	89 44 24 08          	mov    %eax,0x8(%esp)
  800616:	8b 45 0c             	mov    0xc(%ebp),%eax
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 02 00 00 00       	call   80062a <vprintfmt>
	va_end(ap);
}
  800628:	c9                   	leave  
  800629:	c3                   	ret    

0080062a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	57                   	push   %edi
  80062e:	56                   	push   %esi
  80062f:	53                   	push   %ebx
  800630:	83 ec 4c             	sub    $0x4c,%esp
  800633:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800636:	8b 75 10             	mov    0x10(%ebp),%esi
  800639:	eb 12                	jmp    80064d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80063b:	85 c0                	test   %eax,%eax
  80063d:	0f 84 6b 03 00 00    	je     8009ae <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064d:	0f b6 06             	movzbl (%esi),%eax
  800650:	46                   	inc    %esi
  800651:	83 f8 25             	cmp    $0x25,%eax
  800654:	75 e5                	jne    80063b <vprintfmt+0x11>
  800656:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80065a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800661:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800666:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	eb 26                	jmp    80069a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800677:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80067b:	eb 1d                	jmp    80069a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800680:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800684:	eb 14                	jmp    80069a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800689:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800690:	eb 08                	jmp    80069a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800692:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800695:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	0f b6 06             	movzbl (%esi),%eax
  80069d:	8d 56 01             	lea    0x1(%esi),%edx
  8006a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006a3:	8a 16                	mov    (%esi),%dl
  8006a5:	83 ea 23             	sub    $0x23,%edx
  8006a8:	80 fa 55             	cmp    $0x55,%dl
  8006ab:	0f 87 e1 02 00 00    	ja     800992 <vprintfmt+0x368>
  8006b1:	0f b6 d2             	movzbl %dl,%edx
  8006b4:	ff 24 95 a0 11 80 00 	jmp    *0x8011a0(,%edx,4)
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006be:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006c3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006c6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006ca:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006cd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006d0:	83 fa 09             	cmp    $0x9,%edx
  8006d3:	77 2a                	ja     8006ff <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d6:	eb eb                	jmp    8006c3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e6:	eb 17                	jmp    8006ff <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ec:	78 98                	js     800686 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f1:	eb a7                	jmp    80069a <vprintfmt+0x70>
  8006f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006f6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006fd:	eb 9b                	jmp    80069a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800703:	79 95                	jns    80069a <vprintfmt+0x70>
  800705:	eb 8b                	jmp    800692 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800707:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80070b:	eb 8d                	jmp    80069a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800725:	e9 23 ff ff ff       	jmp    80064d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)
  800733:	8b 00                	mov    (%eax),%eax
  800735:	85 c0                	test   %eax,%eax
  800737:	79 02                	jns    80073b <vprintfmt+0x111>
  800739:	f7 d8                	neg    %eax
  80073b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80073d:	83 f8 09             	cmp    $0x9,%eax
  800740:	7f 0b                	jg     80074d <vprintfmt+0x123>
  800742:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  800749:	85 c0                	test   %eax,%eax
  80074b:	75 23                	jne    800770 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80074d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800751:	c7 44 24 08 f5 10 80 	movl   $0x8010f5,0x8(%esp)
  800758:	00 
  800759:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	e8 9a fe ff ff       	call   800602 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800768:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80076b:	e9 dd fe ff ff       	jmp    80064d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800770:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800774:	c7 44 24 08 fe 10 80 	movl   $0x8010fe,0x8(%esp)
  80077b:	00 
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
  800783:	89 14 24             	mov    %edx,(%esp)
  800786:	e8 77 fe ff ff       	call   800602 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078e:	e9 ba fe ff ff       	jmp    80064d <vprintfmt+0x23>
  800793:	89 f9                	mov    %edi,%ecx
  800795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800798:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 04             	lea    0x4(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 30                	mov    (%eax),%esi
  8007a6:	85 f6                	test   %esi,%esi
  8007a8:	75 05                	jne    8007af <vprintfmt+0x185>
				p = "(null)";
  8007aa:	be ee 10 80 00       	mov    $0x8010ee,%esi
			if (width > 0 && padc != '-')
  8007af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b3:	0f 8e 84 00 00 00    	jle    80083d <vprintfmt+0x213>
  8007b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007bd:	74 7e                	je     80083d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007c3:	89 34 24             	mov    %esi,(%esp)
  8007c6:	e8 8b 02 00 00       	call   800a56 <strnlen>
  8007cb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ce:	29 c2                	sub    %eax,%edx
  8007d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007d3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007d7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007da:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007dd:	89 de                	mov    %ebx,%esi
  8007df:	89 d3                	mov    %edx,%ebx
  8007e1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e3:	eb 0b                	jmp    8007f0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	89 3c 24             	mov    %edi,(%esp)
  8007ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ef:	4b                   	dec    %ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f f1                	jg     8007e5 <vprintfmt+0x1bb>
  8007f4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007f7:	89 f3                	mov    %esi,%ebx
  8007f9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ff:	85 c0                	test   %eax,%eax
  800801:	79 05                	jns    800808 <vprintfmt+0x1de>
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80080b:	29 c2                	sub    %eax,%edx
  80080d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800810:	eb 2b                	jmp    80083d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800812:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800816:	74 18                	je     800830 <vprintfmt+0x206>
  800818:	8d 50 e0             	lea    -0x20(%eax),%edx
  80081b:	83 fa 5e             	cmp    $0x5e,%edx
  80081e:	76 10                	jbe    800830 <vprintfmt+0x206>
					putch('?', putdat);
  800820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800824:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80082b:	ff 55 08             	call   *0x8(%ebp)
  80082e:	eb 0a                	jmp    80083a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800830:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80083a:	ff 4d e4             	decl   -0x1c(%ebp)
  80083d:	0f be 06             	movsbl (%esi),%eax
  800840:	46                   	inc    %esi
  800841:	85 c0                	test   %eax,%eax
  800843:	74 21                	je     800866 <vprintfmt+0x23c>
  800845:	85 ff                	test   %edi,%edi
  800847:	78 c9                	js     800812 <vprintfmt+0x1e8>
  800849:	4f                   	dec    %edi
  80084a:	79 c6                	jns    800812 <vprintfmt+0x1e8>
  80084c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084f:	89 de                	mov    %ebx,%esi
  800851:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800854:	eb 18                	jmp    80086e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800856:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800861:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800863:	4b                   	dec    %ebx
  800864:	eb 08                	jmp    80086e <vprintfmt+0x244>
  800866:	8b 7d 08             	mov    0x8(%ebp),%edi
  800869:	89 de                	mov    %ebx,%esi
  80086b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80086e:	85 db                	test   %ebx,%ebx
  800870:	7f e4                	jg     800856 <vprintfmt+0x22c>
  800872:	89 7d 08             	mov    %edi,0x8(%ebp)
  800875:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800877:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80087a:	e9 ce fd ff ff       	jmp    80064d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80087f:	83 f9 01             	cmp    $0x1,%ecx
  800882:	7e 10                	jle    800894 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 50 08             	lea    0x8(%eax),%edx
  80088a:	89 55 14             	mov    %edx,0x14(%ebp)
  80088d:	8b 30                	mov    (%eax),%esi
  80088f:	8b 78 04             	mov    0x4(%eax),%edi
  800892:	eb 26                	jmp    8008ba <vprintfmt+0x290>
	else if (lflag)
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 12                	je     8008aa <vprintfmt+0x280>
		return va_arg(*ap, long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 04             	lea    0x4(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 30                	mov    (%eax),%esi
  8008a3:	89 f7                	mov    %esi,%edi
  8008a5:	c1 ff 1f             	sar    $0x1f,%edi
  8008a8:	eb 10                	jmp    8008ba <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8d 50 04             	lea    0x4(%eax),%edx
  8008b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b3:	8b 30                	mov    (%eax),%esi
  8008b5:	89 f7                	mov    %esi,%edi
  8008b7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008ba:	85 ff                	test   %edi,%edi
  8008bc:	78 0a                	js     8008c8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c3:	e9 8c 00 00 00       	jmp    800954 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008d3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008d6:	f7 de                	neg    %esi
  8008d8:	83 d7 00             	adc    $0x0,%edi
  8008db:	f7 df                	neg    %edi
			}
			base = 10;
  8008dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e2:	eb 70                	jmp    800954 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e4:	89 ca                	mov    %ecx,%edx
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e9:	e8 c0 fc ff ff       	call   8005ae <getuint>
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008f7:	eb 5b                	jmp    800954 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8008f9:	89 ca                	mov    %ecx,%edx
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fe:	e8 ab fc ff ff       	call   8005ae <getuint>
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d7                	mov    %edx,%edi
                        base = 8;
  800907:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  80090c:	eb 46                	jmp    800954 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  80090e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800912:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800919:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80091c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800920:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800933:	8b 30                	mov    (%eax),%esi
  800935:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80093a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80093f:	eb 13                	jmp    800954 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800941:	89 ca                	mov    %ecx,%edx
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
  800946:	e8 63 fc ff ff       	call   8005ae <getuint>
  80094b:	89 c6                	mov    %eax,%esi
  80094d:	89 d7                	mov    %edx,%edi
			base = 16;
  80094f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800954:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800958:	89 54 24 10          	mov    %edx,0x10(%esp)
  80095c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80095f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800963:	89 44 24 08          	mov    %eax,0x8(%esp)
  800967:	89 34 24             	mov    %esi,(%esp)
  80096a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096e:	89 da                	mov    %ebx,%edx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	e8 6c fb ff ff       	call   8004e4 <printnum>
			break;
  800978:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80097b:	e9 cd fc ff ff       	jmp    80064d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800984:	89 04 24             	mov    %eax,(%esp)
  800987:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80098d:	e9 bb fc ff ff       	jmp    80064d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800996:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80099d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a0:	eb 01                	jmp    8009a3 <vprintfmt+0x379>
  8009a2:	4e                   	dec    %esi
  8009a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009a7:	75 f9                	jne    8009a2 <vprintfmt+0x378>
  8009a9:	e9 9f fc ff ff       	jmp    80064d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009ae:	83 c4 4c             	add    $0x4c,%esp
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 28             	sub    $0x28,%esp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	74 30                	je     800a07 <vsnprintf+0x51>
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	7e 33                	jle    800a0e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009db:	8b 45 14             	mov    0x14(%ebp),%eax
  8009de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	c7 04 24 e8 05 80 00 	movl   $0x8005e8,(%esp)
  8009f7:	e8 2e fc ff ff       	call   80062a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a05:	eb 0c                	jmp    800a13 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0c:	eb 05                	jmp    800a13 <vsnprintf+0x5d>
  800a0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
  800a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 7b ff ff ff       	call   8009b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    
  800a3d:	00 00                	add    %al,(%eax)
	...

00800a40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	eb 01                	jmp    800a4e <strlen+0xe>
		n++;
  800a4d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a52:	75 f9                	jne    800a4d <strlen+0xd>
		n++;
	return n;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	eb 01                	jmp    800a67 <strnlen+0x11>
		n++;
  800a66:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	74 06                	je     800a71 <strnlen+0x1b>
  800a6b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a6f:	75 f5                	jne    800a66 <strnlen+0x10>
		n++;
	return n;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	53                   	push   %ebx
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a85:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a88:	42                   	inc    %edx
  800a89:	84 c9                	test   %cl,%cl
  800a8b:	75 f5                	jne    800a82 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9a:	89 1c 24             	mov    %ebx,(%esp)
  800a9d:	e8 9e ff ff ff       	call   800a40 <strlen>
	strcpy(dst + len, src);
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa9:	01 d8                	add    %ebx,%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 c0 ff ff ff       	call   800a73 <strcpy>
	return dst;
}
  800ab3:	89 d8                	mov    %ebx,%eax
  800ab5:	83 c4 08             	add    $0x8,%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	eb 0c                	jmp    800adc <strncpy+0x21>
		*dst++ = *src;
  800ad0:	8a 1a                	mov    (%edx),%bl
  800ad2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ad8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800adb:	41                   	inc    %ecx
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	75 f0                	jne    800ad0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aef:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af2:	85 d2                	test   %edx,%edx
  800af4:	75 0a                	jne    800b00 <strlcpy+0x1c>
  800af6:	89 f0                	mov    %esi,%eax
  800af8:	eb 1a                	jmp    800b14 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800afa:	88 18                	mov    %bl,(%eax)
  800afc:	40                   	inc    %eax
  800afd:	41                   	inc    %ecx
  800afe:	eb 02                	jmp    800b02 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b00:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b02:	4a                   	dec    %edx
  800b03:	74 0a                	je     800b0f <strlcpy+0x2b>
  800b05:	8a 19                	mov    (%ecx),%bl
  800b07:	84 db                	test   %bl,%bl
  800b09:	75 ef                	jne    800afa <strlcpy+0x16>
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	eb 02                	jmp    800b11 <strlcpy+0x2d>
  800b0f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b11:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b14:	29 f0                	sub    %esi,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b23:	eb 02                	jmp    800b27 <strcmp+0xd>
		p++, q++;
  800b25:	41                   	inc    %ecx
  800b26:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b27:	8a 01                	mov    (%ecx),%al
  800b29:	84 c0                	test   %al,%al
  800b2b:	74 04                	je     800b31 <strcmp+0x17>
  800b2d:	3a 02                	cmp    (%edx),%al
  800b2f:	74 f4                	je     800b25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	0f b6 c0             	movzbl %al,%eax
  800b34:	0f b6 12             	movzbl (%edx),%edx
  800b37:	29 d0                	sub    %edx,%eax
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b48:	eb 03                	jmp    800b4d <strncmp+0x12>
		n--, p++, q++;
  800b4a:	4a                   	dec    %edx
  800b4b:	40                   	inc    %eax
  800b4c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4d:	85 d2                	test   %edx,%edx
  800b4f:	74 14                	je     800b65 <strncmp+0x2a>
  800b51:	8a 18                	mov    (%eax),%bl
  800b53:	84 db                	test   %bl,%bl
  800b55:	74 04                	je     800b5b <strncmp+0x20>
  800b57:	3a 19                	cmp    (%ecx),%bl
  800b59:	74 ef                	je     800b4a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5b:	0f b6 00             	movzbl (%eax),%eax
  800b5e:	0f b6 11             	movzbl (%ecx),%edx
  800b61:	29 d0                	sub    %edx,%eax
  800b63:	eb 05                	jmp    800b6a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b76:	eb 05                	jmp    800b7d <strchr+0x10>
		if (*s == c)
  800b78:	38 ca                	cmp    %cl,%dl
  800b7a:	74 0c                	je     800b88 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b7c:	40                   	inc    %eax
  800b7d:	8a 10                	mov    (%eax),%dl
  800b7f:	84 d2                	test   %dl,%dl
  800b81:	75 f5                	jne    800b78 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b93:	eb 05                	jmp    800b9a <strfind+0x10>
		if (*s == c)
  800b95:	38 ca                	cmp    %cl,%dl
  800b97:	74 07                	je     800ba0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b99:	40                   	inc    %eax
  800b9a:	8a 10                	mov    (%eax),%dl
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	75 f5                	jne    800b95 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb1:	85 c9                	test   %ecx,%ecx
  800bb3:	74 30                	je     800be5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bbb:	75 25                	jne    800be2 <memset+0x40>
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 20                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bc2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	c1 e3 08             	shl    $0x8,%ebx
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	c1 e6 18             	shl    $0x18,%esi
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	c1 e0 10             	shl    $0x10,%eax
  800bd4:	09 f0                	or     %esi,%eax
  800bd6:	09 d0                	or     %edx,%eax
  800bd8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bda:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 03                	jmp    800be5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	fc                   	cld    
  800be3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be5:	89 f8                	mov    %edi,%eax
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfa:	39 c6                	cmp    %eax,%esi
  800bfc:	73 34                	jae    800c32 <memmove+0x46>
  800bfe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c01:	39 d0                	cmp    %edx,%eax
  800c03:	73 2d                	jae    800c32 <memmove+0x46>
		s += n;
		d += n;
  800c05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c08:	f6 c2 03             	test   $0x3,%dl
  800c0b:	75 1b                	jne    800c28 <memmove+0x3c>
  800c0d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c13:	75 13                	jne    800c28 <memmove+0x3c>
  800c15:	f6 c1 03             	test   $0x3,%cl
  800c18:	75 0e                	jne    800c28 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1a:	83 ef 04             	sub    $0x4,%edi
  800c1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c20:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c23:	fd                   	std    
  800c24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c26:	eb 07                	jmp    800c2f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c28:	4f                   	dec    %edi
  800c29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2c:	fd                   	std    
  800c2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c2f:	fc                   	cld    
  800c30:	eb 20                	jmp    800c52 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c38:	75 13                	jne    800c4d <memmove+0x61>
  800c3a:	a8 03                	test   $0x3,%al
  800c3c:	75 0f                	jne    800c4d <memmove+0x61>
  800c3e:	f6 c1 03             	test   $0x3,%cl
  800c41:	75 0a                	jne    800c4d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c43:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	fc                   	cld    
  800c49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4b:	eb 05                	jmp    800c52 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4d:	89 c7                	mov    %eax,%edi
  800c4f:	fc                   	cld    
  800c50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6d:	89 04 24             	mov    %eax,(%esp)
  800c70:	e8 77 ff ff ff       	call   800bec <memmove>
}
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	eb 16                	jmp    800ca3 <memcmp+0x2c>
		if (*s1 != *s2)
  800c8d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c90:	42                   	inc    %edx
  800c91:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c95:	38 c8                	cmp    %cl,%al
  800c97:	74 0a                	je     800ca3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c99:	0f b6 c0             	movzbl %al,%eax
  800c9c:	0f b6 c9             	movzbl %cl,%ecx
  800c9f:	29 c8                	sub    %ecx,%eax
  800ca1:	eb 09                	jmp    800cac <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca3:	39 da                	cmp    %ebx,%edx
  800ca5:	75 e6                	jne    800c8d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cba:	89 c2                	mov    %eax,%edx
  800cbc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cbf:	eb 05                	jmp    800cc6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc1:	38 08                	cmp    %cl,(%eax)
  800cc3:	74 05                	je     800cca <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc5:	40                   	inc    %eax
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	72 f7                	jb     800cc1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd8:	eb 01                	jmp    800cdb <strtol+0xf>
		s++;
  800cda:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdb:	8a 02                	mov    (%edx),%al
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 f9                	je     800cda <strtol+0xe>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	74 f5                	je     800cda <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce5:	3c 2b                	cmp    $0x2b,%al
  800ce7:	75 08                	jne    800cf1 <strtol+0x25>
		s++;
  800ce9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cea:	bf 00 00 00 00       	mov    $0x0,%edi
  800cef:	eb 13                	jmp    800d04 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cf1:	3c 2d                	cmp    $0x2d,%al
  800cf3:	75 0a                	jne    800cff <strtol+0x33>
		s++, neg = 1;
  800cf5:	8d 52 01             	lea    0x1(%edx),%edx
  800cf8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cfd:	eb 05                	jmp    800d04 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d04:	85 db                	test   %ebx,%ebx
  800d06:	74 05                	je     800d0d <strtol+0x41>
  800d08:	83 fb 10             	cmp    $0x10,%ebx
  800d0b:	75 28                	jne    800d35 <strtol+0x69>
  800d0d:	8a 02                	mov    (%edx),%al
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 10                	jne    800d23 <strtol+0x57>
  800d13:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d17:	75 0a                	jne    800d23 <strtol+0x57>
		s += 2, base = 16;
  800d19:	83 c2 02             	add    $0x2,%edx
  800d1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d21:	eb 12                	jmp    800d35 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d23:	85 db                	test   %ebx,%ebx
  800d25:	75 0e                	jne    800d35 <strtol+0x69>
  800d27:	3c 30                	cmp    $0x30,%al
  800d29:	75 05                	jne    800d30 <strtol+0x64>
		s++, base = 8;
  800d2b:	42                   	inc    %edx
  800d2c:	b3 08                	mov    $0x8,%bl
  800d2e:	eb 05                	jmp    800d35 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d30:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3c:	8a 0a                	mov    (%edx),%cl
  800d3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d41:	80 fb 09             	cmp    $0x9,%bl
  800d44:	77 08                	ja     800d4e <strtol+0x82>
			dig = *s - '0';
  800d46:	0f be c9             	movsbl %cl,%ecx
  800d49:	83 e9 30             	sub    $0x30,%ecx
  800d4c:	eb 1e                	jmp    800d6c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d51:	80 fb 19             	cmp    $0x19,%bl
  800d54:	77 08                	ja     800d5e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 57             	sub    $0x57,%ecx
  800d5c:	eb 0e                	jmp    800d6c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d61:	80 fb 19             	cmp    $0x19,%bl
  800d64:	77 12                	ja     800d78 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d66:	0f be c9             	movsbl %cl,%ecx
  800d69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d6c:	39 f1                	cmp    %esi,%ecx
  800d6e:	7d 0c                	jge    800d7c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d70:	42                   	inc    %edx
  800d71:	0f af c6             	imul   %esi,%eax
  800d74:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d76:	eb c4                	jmp    800d3c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d78:	89 c1                	mov    %eax,%ecx
  800d7a:	eb 02                	jmp    800d7e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d7c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d82:	74 05                	je     800d89 <strtol+0xbd>
		*endptr = (char *) s;
  800d84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d87:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d89:	85 ff                	test   %edi,%edi
  800d8b:	74 04                	je     800d91 <strtol+0xc5>
  800d8d:	89 c8                	mov    %ecx,%eax
  800d8f:	f7 d8                	neg    %eax
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
	...

00800d98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d9e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800da5:	75 3d                	jne    800de4 <set_pgfault_handler+0x4c>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
                if(sys_page_alloc(sys_getenvid(), (void*)(UXSTACKTOP - PGSIZE), PTE_SYSCALL) < 0)
  800da7:	e8 a7 f3 ff ff       	call   800153 <sys_getenvid>
  800dac:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dbb:	ee 
  800dbc:	89 04 24             	mov    %eax,(%esp)
  800dbf:	e8 cd f3 ff ff       	call   800191 <sys_page_alloc>
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	79 1c                	jns    800de4 <set_pgfault_handler+0x4c>
                    panic("set_pgfault_handler fail at sys_page_alloc!\n");
  800dc8:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800dd7:	00 
  800dd8:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  800ddf:	e8 ec f5 ff ff       	call   8003d0 <_panic>
                
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	a3 08 20 80 00       	mov    %eax,0x802008
        if(sys_env_set_pgfault_upcall(sys_getenvid(), (void*)_pgfault_upcall) < 0)
  800dec:	e8 62 f3 ff ff       	call   800153 <sys_getenvid>
  800df1:	c7 44 24 04 a8 03 80 	movl   $0x8003a8,0x4(%esp)
  800df8:	00 
  800df9:	89 04 24             	mov    %eax,(%esp)
  800dfc:	e8 dd f4 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
  800e01:	85 c0                	test   %eax,%eax
  800e03:	79 1c                	jns    800e21 <set_pgfault_handler+0x89>
            panic("set_pgfault_handler fail at upcall!\n");
  800e05:	c7 44 24 08 58 13 80 	movl   $0x801358,0x8(%esp)
  800e0c:	00 
  800e0d:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800e14:	00 
  800e15:	c7 04 24 80 13 80 00 	movl   $0x801380,(%esp)
  800e1c:	e8 af f5 ff ff       	call   8003d0 <_panic>
}
  800e21:	c9                   	leave  
  800e22:	c3                   	ret    
	...

00800e24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e24:	55                   	push   %ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	83 ec 10             	sub    $0x10,%esp
  800e2a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e2e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e36:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e3a:	89 cd                	mov    %ecx,%ebp
  800e3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	75 2c                	jne    800e70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e44:	39 f9                	cmp    %edi,%ecx
  800e46:	77 68                	ja     800eb0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e48:	85 c9                	test   %ecx,%ecx
  800e4a:	75 0b                	jne    800e57 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	f7 f1                	div    %ecx
  800e55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e57:	31 d2                	xor    %edx,%edx
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	f7 f1                	div    %ecx
  800e5d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e5f:	89 f0                	mov    %esi,%eax
  800e61:	f7 f1                	div    %ecx
  800e63:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e65:	89 f0                	mov    %esi,%eax
  800e67:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e70:	39 f8                	cmp    %edi,%eax
  800e72:	77 2c                	ja     800ea0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e74:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e77:	83 f6 1f             	xor    $0x1f,%esi
  800e7a:	75 4c                	jne    800ec8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e7e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e83:	72 0a                	jb     800e8f <__udivdi3+0x6b>
  800e85:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e89:	0f 87 ad 00 00 00    	ja     800f3c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e8f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e94:	89 f0                	mov    %esi,%eax
  800e96:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea0:	31 ff                	xor    %edi,%edi
  800ea2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea4:	89 f0                	mov    %esi,%eax
  800ea6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    
  800eaf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb0:	89 fa                	mov    %edi,%edx
  800eb2:	89 f0                	mov    %esi,%eax
  800eb4:	f7 f1                	div    %ecx
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec8:	89 f1                	mov    %esi,%ecx
  800eca:	d3 e0                	shl    %cl,%eax
  800ecc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ed0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ed7:	89 ea                	mov    %ebp,%edx
  800ed9:	88 c1                	mov    %al,%cl
  800edb:	d3 ea                	shr    %cl,%edx
  800edd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ee1:	09 ca                	or     %ecx,%edx
  800ee3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ee7:	89 f1                	mov    %esi,%ecx
  800ee9:	d3 e5                	shl    %cl,%ebp
  800eeb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800eef:	89 fd                	mov    %edi,%ebp
  800ef1:	88 c1                	mov    %al,%cl
  800ef3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800ef5:	89 fa                	mov    %edi,%edx
  800ef7:	89 f1                	mov    %esi,%ecx
  800ef9:	d3 e2                	shl    %cl,%edx
  800efb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eff:	88 c1                	mov    %al,%cl
  800f01:	d3 ef                	shr    %cl,%edi
  800f03:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f05:	89 f8                	mov    %edi,%eax
  800f07:	89 ea                	mov    %ebp,%edx
  800f09:	f7 74 24 08          	divl   0x8(%esp)
  800f0d:	89 d1                	mov    %edx,%ecx
  800f0f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f11:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f15:	39 d1                	cmp    %edx,%ecx
  800f17:	72 17                	jb     800f30 <__udivdi3+0x10c>
  800f19:	74 09                	je     800f24 <__udivdi3+0x100>
  800f1b:	89 fe                	mov    %edi,%esi
  800f1d:	31 ff                	xor    %edi,%edi
  800f1f:	e9 41 ff ff ff       	jmp    800e65 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f24:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f28:	89 f1                	mov    %esi,%ecx
  800f2a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2c:	39 c2                	cmp    %eax,%edx
  800f2e:	73 eb                	jae    800f1b <__udivdi3+0xf7>
		{
		  q0--;
  800f30:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f33:	31 ff                	xor    %edi,%edi
  800f35:	e9 2b ff ff ff       	jmp    800e65 <__udivdi3+0x41>
  800f3a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f3c:	31 f6                	xor    %esi,%esi
  800f3e:	e9 22 ff ff ff       	jmp    800e65 <__udivdi3+0x41>
	...

00800f44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f44:	55                   	push   %ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	83 ec 20             	sub    $0x20,%esp
  800f4a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f52:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f56:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f62:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f64:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f66:	85 ed                	test   %ebp,%ebp
  800f68:	75 16                	jne    800f80 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f6a:	39 f1                	cmp    %esi,%ecx
  800f6c:	0f 86 a6 00 00 00    	jbe    801018 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f72:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f74:	89 d0                	mov    %edx,%eax
  800f76:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
  800f7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f80:	39 f5                	cmp    %esi,%ebp
  800f82:	0f 87 ac 00 00 00    	ja     801034 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f88:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f8b:	83 f0 1f             	xor    $0x1f,%eax
  800f8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f92:	0f 84 a8 00 00 00    	je     801040 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f98:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f9c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f9e:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fa7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	d3 e8                	shr    %cl,%eax
  800faf:	09 e8                	or     %ebp,%eax
  800fb1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fb5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fc7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fcb:	d3 e0                	shl    %cl,%eax
  800fcd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fd1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd5:	89 f9                	mov    %edi,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fdb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fdd:	89 f2                	mov    %esi,%edx
  800fdf:	f7 74 24 18          	divl   0x18(%esp)
  800fe3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fe5:	f7 64 24 0c          	mull   0xc(%esp)
  800fe9:	89 c5                	mov    %eax,%ebp
  800feb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fed:	39 d6                	cmp    %edx,%esi
  800fef:	72 67                	jb     801058 <__umoddi3+0x114>
  800ff1:	74 75                	je     801068 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ff3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ff7:	29 e8                	sub    %ebp,%eax
  800ff9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ffb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fff:	d3 e8                	shr    %cl,%eax
  801001:	89 f2                	mov    %esi,%edx
  801003:	89 f9                	mov    %edi,%ecx
  801005:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801007:	09 d0                	or     %edx,%eax
  801009:	89 f2                	mov    %esi,%edx
  80100b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80100f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801018:	85 c9                	test   %ecx,%ecx
  80101a:	75 0b                	jne    801027 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80101c:	b8 01 00 00 00       	mov    $0x1,%eax
  801021:	31 d2                	xor    %edx,%edx
  801023:	f7 f1                	div    %ecx
  801025:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801027:	89 f0                	mov    %esi,%eax
  801029:	31 d2                	xor    %edx,%edx
  80102b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80102d:	89 f8                	mov    %edi,%eax
  80102f:	e9 3e ff ff ff       	jmp    800f72 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801034:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801040:	39 f5                	cmp    %esi,%ebp
  801042:	72 04                	jb     801048 <__umoddi3+0x104>
  801044:	39 f9                	cmp    %edi,%ecx
  801046:	77 06                	ja     80104e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801048:	89 f2                	mov    %esi,%edx
  80104a:	29 cf                	sub    %ecx,%edi
  80104c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80104e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801050:	83 c4 20             	add    $0x20,%esp
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801058:	89 d1                	mov    %edx,%ecx
  80105a:	89 c5                	mov    %eax,%ebp
  80105c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801060:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801064:	eb 8d                	jmp    800ff3 <__umoddi3+0xaf>
  801066:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801068:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80106c:	72 ea                	jb     801058 <__umoddi3+0x114>
  80106e:	89 f1                	mov    %esi,%ecx
  801070:	eb 81                	jmp    800ff3 <__umoddi3+0xaf>
