
obj/user/buggyhello2：     文件格式 elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 6d 00 00 00       	call   8000bc <sys_cputs>
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
  800062:	e8 e4 00 00 00       	call   80014b <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 04 20 80 00       	mov    %eax,0x802004

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
  8000b5:	e8 3f 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	b8 03 00 00 00       	mov    $0x3,%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7e 28                	jle    800143 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800126:	00 
  800127:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  80013e:	e8 5d 02 00 00       	call   8003a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800143:	83 c4 2c             	add    $0x2c,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 0a 00 00 00       	mov    $0xa,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	b8 04 00 00 00       	mov    $0x4,%eax
  80019c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7e 28                	jle    8001d5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  8001d0:	e8 cb 01 00 00       	call   8003a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d5:	83 c4 2c             	add    $0x2c,%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5f                   	pop    %edi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7e 28                	jle    800228 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800200:	89 44 24 10          	mov    %eax,0x10(%esp)
  800204:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020b:	00 
  80020c:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  800223:	e8 78 01 00 00       	call   8003a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800228:	83 c4 2c             	add    $0x2c,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7e 28                	jle    80027b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800253:	89 44 24 10          	mov    %eax,0x10(%esp)
  800257:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025e:	00 
  80025f:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  800266:	00 
  800267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026e:	00 
  80026f:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  800276:	e8 25 01 00 00       	call   8003a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027b:	83 c4 2c             	add    $0x2c,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 08 00 00 00       	mov    $0x8,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 28                	jle    8002ce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002aa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  8002c9:	e8 d2 00 00 00       	call   8003a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ce:	83 c4 2c             	add    $0x2c,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	89 df                	mov    %ebx,%edi
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 28                	jle    800321 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800304:	00 
  800305:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  80030c:	00 
  80030d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800314:	00 
  800315:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  80031c:	e8 7f 00 00 00       	call   8003a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800321:	83 c4 2c             	add    $0x2c,%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032f:	be 00 00 00 00       	mov    $0x0,%esi
  800334:	b8 0b 00 00 00       	mov    $0xb,%eax
  800339:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800347:	5b                   	pop    %ebx
  800348:	5e                   	pop    %esi
  800349:	5f                   	pop    %edi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80035f:	8b 55 08             	mov    0x8(%ebp),%edx
  800362:	89 cb                	mov    %ecx,%ebx
  800364:	89 cf                	mov    %ecx,%edi
  800366:	89 ce                	mov    %ecx,%esi
  800368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 d8 0f 80 	movl   $0x800fd8,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 f5 0f 80 00 	movl   $0x800ff5,(%esp)
  800391:	e8 0a 00 00 00       	call   8003a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800396:	83 c4 2c             	add    $0x2c,%esp
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    
	...

008003a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003ab:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8003b1:	e8 95 fd ff ff       	call   80014b <sys_getenvid>
  8003b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cc:	c7 04 24 04 10 80 00 	movl   $0x801004,(%esp)
  8003d3:	e8 c0 00 00 00       	call   800498 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	e8 50 00 00 00       	call   800437 <vcprintf>
	cprintf("\n");
  8003e7:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  8003ee:	e8 a5 00 00 00       	call   800498 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003f3:	cc                   	int3   
  8003f4:	eb fd                	jmp    8003f3 <_panic+0x53>
	...

008003f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	53                   	push   %ebx
  8003fc:	83 ec 14             	sub    $0x14,%esp
  8003ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800402:	8b 03                	mov    (%ebx),%eax
  800404:	8b 55 08             	mov    0x8(%ebp),%edx
  800407:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80040b:	40                   	inc    %eax
  80040c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80040e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800413:	75 19                	jne    80042e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800415:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80041c:	00 
  80041d:	8d 43 08             	lea    0x8(%ebx),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 94 fc ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800428:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80042e:	ff 43 04             	incl   0x4(%ebx)
}
  800431:	83 c4 14             	add    $0x14,%esp
  800434:	5b                   	pop    %ebx
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800440:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800447:	00 00 00 
	b.cnt = 0;
  80044a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800451:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800462:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800468:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046c:	c7 04 24 f8 03 80 00 	movl   $0x8003f8,(%esp)
  800473:	e8 82 01 00 00       	call   8005fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800478:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80047e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800482:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	e8 2c fc ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  800490:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800496:	c9                   	leave  
  800497:	c3                   	ret    

00800498 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80049e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 87 ff ff ff       	call   800437 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    
	...

008004b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	57                   	push   %edi
  8004b8:	56                   	push   %esi
  8004b9:	53                   	push   %ebx
  8004ba:	83 ec 3c             	sub    $0x3c,%esp
  8004bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c0:	89 d7                	mov    %edx,%edi
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	75 08                	jne    8004e0 <printnum+0x2c>
  8004d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004de:	77 57                	ja     800537 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004e4:	4b                   	dec    %ebx
  8004e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ff:	00 
  800500:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	e8 56 08 00 00       	call   800d68 <__udivdi3>
  800512:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800516:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800521:	89 fa                	mov    %edi,%edx
  800523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800526:	e8 89 ff ff ff       	call   8004b4 <printnum>
  80052b:	eb 0f                	jmp    80053c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80052d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800531:	89 34 24             	mov    %esi,(%esp)
  800534:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800537:	4b                   	dec    %ebx
  800538:	85 db                	test   %ebx,%ebx
  80053a:	7f f1                	jg     80052d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 10             	mov    0x10(%ebp),%eax
  800547:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800552:	00 
  800553:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800556:	89 04 24             	mov    %eax,(%esp)
  800559:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800560:	e8 23 09 00 00       	call   800e88 <__umoddi3>
  800565:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800569:	0f be 80 28 10 80 00 	movsbl 0x801028(%eax),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800576:	83 c4 3c             	add    $0x3c,%esp
  800579:	5b                   	pop    %ebx
  80057a:	5e                   	pop    %esi
  80057b:	5f                   	pop    %edi
  80057c:	5d                   	pop    %ebp
  80057d:	c3                   	ret    

0080057e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800581:	83 fa 01             	cmp    $0x1,%edx
  800584:	7e 0e                	jle    800594 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800586:	8b 10                	mov    (%eax),%edx
  800588:	8d 4a 08             	lea    0x8(%edx),%ecx
  80058b:	89 08                	mov    %ecx,(%eax)
  80058d:	8b 02                	mov    (%edx),%eax
  80058f:	8b 52 04             	mov    0x4(%edx),%edx
  800592:	eb 22                	jmp    8005b6 <getuint+0x38>
	else if (lflag)
  800594:	85 d2                	test   %edx,%edx
  800596:	74 10                	je     8005a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059d:	89 08                	mov    %ecx,(%eax)
  80059f:	8b 02                	mov    (%edx),%eax
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a6:	eb 0e                	jmp    8005b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ad:	89 08                	mov    %ecx,(%eax)
  8005af:	8b 02                	mov    (%edx),%eax
  8005b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c6:	73 08                	jae    8005d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005cb:	88 0a                	mov    %cl,(%edx)
  8005cd:	42                   	inc    %edx
  8005ce:	89 10                	mov    %edx,(%eax)
}
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005df:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	e8 02 00 00 00       	call   8005fa <vprintfmt>
	va_end(ap);
}
  8005f8:	c9                   	leave  
  8005f9:	c3                   	ret    

008005fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005fa:	55                   	push   %ebp
  8005fb:	89 e5                	mov    %esp,%ebp
  8005fd:	57                   	push   %edi
  8005fe:	56                   	push   %esi
  8005ff:	53                   	push   %ebx
  800600:	83 ec 4c             	sub    $0x4c,%esp
  800603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800606:	8b 75 10             	mov    0x10(%ebp),%esi
  800609:	eb 12                	jmp    80061d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80060b:	85 c0                	test   %eax,%eax
  80060d:	0f 84 6b 03 00 00    	je     80097e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800613:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80061d:	0f b6 06             	movzbl (%esi),%eax
  800620:	46                   	inc    %esi
  800621:	83 f8 25             	cmp    $0x25,%eax
  800624:	75 e5                	jne    80060b <vprintfmt+0x11>
  800626:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80062a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800631:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800636:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	eb 26                	jmp    80066a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800647:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80064b:	eb 1d                	jmp    80066a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800650:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800654:	eb 14                	jmp    80066a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800659:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800660:	eb 08                	jmp    80066a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800662:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800665:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	0f b6 06             	movzbl (%esi),%eax
  80066d:	8d 56 01             	lea    0x1(%esi),%edx
  800670:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800673:	8a 16                	mov    (%esi),%dl
  800675:	83 ea 23             	sub    $0x23,%edx
  800678:	80 fa 55             	cmp    $0x55,%dl
  80067b:	0f 87 e1 02 00 00    	ja     800962 <vprintfmt+0x368>
  800681:	0f b6 d2             	movzbl %dl,%edx
  800684:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  80068b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800693:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800696:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80069a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80069d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006a0:	83 fa 09             	cmp    $0x9,%edx
  8006a3:	77 2a                	ja     8006cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006a6:	eb eb                	jmp    800693 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006b6:	eb 17                	jmp    8006cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bc:	78 98                	js     800656 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c1:	eb a7                	jmp    80066a <vprintfmt+0x70>
  8006c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006cd:	eb 9b                	jmp    80066a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d3:	79 95                	jns    80066a <vprintfmt+0x70>
  8006d5:	eb 8b                	jmp    800662 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006db:	eb 8d                	jmp    80066a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f5:	e9 23 ff ff ff       	jmp    80061d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	85 c0                	test   %eax,%eax
  800707:	79 02                	jns    80070b <vprintfmt+0x111>
  800709:	f7 d8                	neg    %eax
  80070b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070d:	83 f8 09             	cmp    $0x9,%eax
  800710:	7f 0b                	jg     80071d <vprintfmt+0x123>
  800712:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800719:	85 c0                	test   %eax,%eax
  80071b:	75 23                	jne    800740 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80071d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800721:	c7 44 24 08 40 10 80 	movl   $0x801040,0x8(%esp)
  800728:	00 
  800729:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	e8 9a fe ff ff       	call   8005d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80073b:	e9 dd fe ff ff       	jmp    80061d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800744:	c7 44 24 08 49 10 80 	movl   $0x801049,0x8(%esp)
  80074b:	00 
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	8b 55 08             	mov    0x8(%ebp),%edx
  800753:	89 14 24             	mov    %edx,(%esp)
  800756:	e8 77 fe ff ff       	call   8005d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075e:	e9 ba fe ff ff       	jmp    80061d <vprintfmt+0x23>
  800763:	89 f9                	mov    %edi,%ecx
  800765:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800768:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)
  800774:	8b 30                	mov    (%eax),%esi
  800776:	85 f6                	test   %esi,%esi
  800778:	75 05                	jne    80077f <vprintfmt+0x185>
				p = "(null)";
  80077a:	be 39 10 80 00       	mov    $0x801039,%esi
			if (width > 0 && padc != '-')
  80077f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800783:	0f 8e 84 00 00 00    	jle    80080d <vprintfmt+0x213>
  800789:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80078d:	74 7e                	je     80080d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80078f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800793:	89 34 24             	mov    %esi,(%esp)
  800796:	e8 8b 02 00 00       	call   800a26 <strnlen>
  80079b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80079e:	29 c2                	sub    %eax,%edx
  8007a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007ad:	89 de                	mov    %ebx,%esi
  8007af:	89 d3                	mov    %edx,%ebx
  8007b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b3:	eb 0b                	jmp    8007c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	89 3c 24             	mov    %edi,(%esp)
  8007bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bf:	4b                   	dec    %ebx
  8007c0:	85 db                	test   %ebx,%ebx
  8007c2:	7f f1                	jg     8007b5 <vprintfmt+0x1bb>
  8007c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007c7:	89 f3                	mov    %esi,%ebx
  8007c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	79 05                	jns    8007d8 <vprintfmt+0x1de>
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007db:	29 c2                	sub    %eax,%edx
  8007dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007e0:	eb 2b                	jmp    80080d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e6:	74 18                	je     800800 <vprintfmt+0x206>
  8007e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007eb:	83 fa 5e             	cmp    $0x5e,%edx
  8007ee:	76 10                	jbe    800800 <vprintfmt+0x206>
					putch('?', putdat);
  8007f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007fb:	ff 55 08             	call   *0x8(%ebp)
  8007fe:	eb 0a                	jmp    80080a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080a:	ff 4d e4             	decl   -0x1c(%ebp)
  80080d:	0f be 06             	movsbl (%esi),%eax
  800810:	46                   	inc    %esi
  800811:	85 c0                	test   %eax,%eax
  800813:	74 21                	je     800836 <vprintfmt+0x23c>
  800815:	85 ff                	test   %edi,%edi
  800817:	78 c9                	js     8007e2 <vprintfmt+0x1e8>
  800819:	4f                   	dec    %edi
  80081a:	79 c6                	jns    8007e2 <vprintfmt+0x1e8>
  80081c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081f:	89 de                	mov    %ebx,%esi
  800821:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800824:	eb 18                	jmp    80083e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800831:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800833:	4b                   	dec    %ebx
  800834:	eb 08                	jmp    80083e <vprintfmt+0x244>
  800836:	8b 7d 08             	mov    0x8(%ebp),%edi
  800839:	89 de                	mov    %ebx,%esi
  80083b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80083e:	85 db                	test   %ebx,%ebx
  800840:	7f e4                	jg     800826 <vprintfmt+0x22c>
  800842:	89 7d 08             	mov    %edi,0x8(%ebp)
  800845:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800847:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80084a:	e9 ce fd ff ff       	jmp    80061d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084f:	83 f9 01             	cmp    $0x1,%ecx
  800852:	7e 10                	jle    800864 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 08             	lea    0x8(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 30                	mov    (%eax),%esi
  80085f:	8b 78 04             	mov    0x4(%eax),%edi
  800862:	eb 26                	jmp    80088a <vprintfmt+0x290>
	else if (lflag)
  800864:	85 c9                	test   %ecx,%ecx
  800866:	74 12                	je     80087a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 30                	mov    (%eax),%esi
  800873:	89 f7                	mov    %esi,%edi
  800875:	c1 ff 1f             	sar    $0x1f,%edi
  800878:	eb 10                	jmp    80088a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 50 04             	lea    0x4(%eax),%edx
  800880:	89 55 14             	mov    %edx,0x14(%ebp)
  800883:	8b 30                	mov    (%eax),%esi
  800885:	89 f7                	mov    %esi,%edi
  800887:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80088a:	85 ff                	test   %edi,%edi
  80088c:	78 0a                	js     800898 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80088e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800893:	e9 8c 00 00 00       	jmp    800924 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800898:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008a6:	f7 de                	neg    %esi
  8008a8:	83 d7 00             	adc    $0x0,%edi
  8008ab:	f7 df                	neg    %edi
			}
			base = 10;
  8008ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008b2:	eb 70                	jmp    800924 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008b4:	89 ca                	mov    %ecx,%edx
  8008b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b9:	e8 c0 fc ff ff       	call   80057e <getuint>
  8008be:	89 c6                	mov    %eax,%esi
  8008c0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008c7:	eb 5b                	jmp    800924 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8008c9:	89 ca                	mov    %ecx,%edx
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ce:	e8 ab fc ff ff       	call   80057e <getuint>
  8008d3:	89 c6                	mov    %eax,%esi
  8008d5:	89 d7                	mov    %edx,%edi
                        base = 8;
  8008d7:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8008dc:	eb 46                	jmp    800924 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8008de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008f7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8d 50 04             	lea    0x4(%eax),%edx
  800900:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800903:	8b 30                	mov    (%eax),%esi
  800905:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80090a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80090f:	eb 13                	jmp    800924 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800911:	89 ca                	mov    %ecx,%edx
  800913:	8d 45 14             	lea    0x14(%ebp),%eax
  800916:	e8 63 fc ff ff       	call   80057e <getuint>
  80091b:	89 c6                	mov    %eax,%esi
  80091d:	89 d7                	mov    %edx,%edi
			base = 16;
  80091f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800924:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800928:	89 54 24 10          	mov    %edx,0x10(%esp)
  80092c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800933:	89 44 24 08          	mov    %eax,0x8(%esp)
  800937:	89 34 24             	mov    %esi,(%esp)
  80093a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093e:	89 da                	mov    %ebx,%edx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	e8 6c fb ff ff       	call   8004b4 <printnum>
			break;
  800948:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80094b:	e9 cd fc ff ff       	jmp    80061d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	89 04 24             	mov    %eax,(%esp)
  800957:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80095d:	e9 bb fc ff ff       	jmp    80061d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800962:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800966:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80096d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800970:	eb 01                	jmp    800973 <vprintfmt+0x379>
  800972:	4e                   	dec    %esi
  800973:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800977:	75 f9                	jne    800972 <vprintfmt+0x378>
  800979:	e9 9f fc ff ff       	jmp    80061d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80097e:	83 c4 4c             	add    $0x4c,%esp
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 28             	sub    $0x28,%esp
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800992:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800995:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800999:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	74 30                	je     8009d7 <vsnprintf+0x51>
  8009a7:	85 d2                	test   %edx,%edx
  8009a9:	7e 33                	jle    8009de <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	c7 04 24 b8 05 80 00 	movl   $0x8005b8,(%esp)
  8009c7:	e8 2e fc ff ff       	call   8005fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d5:	eb 0c                	jmp    8009e3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009dc:	eb 05                	jmp    8009e3 <vsnprintf+0x5d>
  8009de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 7b ff ff ff       	call   800986 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    
  800a0d:	00 00                	add    %al,(%eax)
	...

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	eb 01                	jmp    800a1e <strlen+0xe>
		n++;
  800a1d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a22:	75 f9                	jne    800a1d <strlen+0xd>
		n++;
	return n;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	eb 01                	jmp    800a37 <strnlen+0x11>
		n++;
  800a36:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	74 06                	je     800a41 <strnlen+0x1b>
  800a3b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a3f:	75 f5                	jne    800a36 <strnlen+0x10>
		n++;
	return n;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	53                   	push   %ebx
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a55:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a58:	42                   	inc    %edx
  800a59:	84 c9                	test   %cl,%cl
  800a5b:	75 f5                	jne    800a52 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a6a:	89 1c 24             	mov    %ebx,(%esp)
  800a6d:	e8 9e ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a75:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a79:	01 d8                	add    %ebx,%eax
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	e8 c0 ff ff ff       	call   800a43 <strcpy>
	return dst;
}
  800a83:	89 d8                	mov    %ebx,%eax
  800a85:	83 c4 08             	add    $0x8,%esp
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a96:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9e:	eb 0c                	jmp    800aac <strncpy+0x21>
		*dst++ = *src;
  800aa0:	8a 1a                	mov    (%edx),%bl
  800aa2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa5:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aab:	41                   	inc    %ecx
  800aac:	39 f1                	cmp    %esi,%ecx
  800aae:	75 f0                	jne    800aa0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 75 08             	mov    0x8(%ebp),%esi
  800abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	75 0a                	jne    800ad0 <strlcpy+0x1c>
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	eb 1a                	jmp    800ae4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aca:	88 18                	mov    %bl,(%eax)
  800acc:	40                   	inc    %eax
  800acd:	41                   	inc    %ecx
  800ace:	eb 02                	jmp    800ad2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ad2:	4a                   	dec    %edx
  800ad3:	74 0a                	je     800adf <strlcpy+0x2b>
  800ad5:	8a 19                	mov    (%ecx),%bl
  800ad7:	84 db                	test   %bl,%bl
  800ad9:	75 ef                	jne    800aca <strlcpy+0x16>
  800adb:	89 c2                	mov    %eax,%edx
  800add:	eb 02                	jmp    800ae1 <strlcpy+0x2d>
  800adf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ae1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ae4:	29 f0                	sub    %esi,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af3:	eb 02                	jmp    800af7 <strcmp+0xd>
		p++, q++;
  800af5:	41                   	inc    %ecx
  800af6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af7:	8a 01                	mov    (%ecx),%al
  800af9:	84 c0                	test   %al,%al
  800afb:	74 04                	je     800b01 <strcmp+0x17>
  800afd:	3a 02                	cmp    (%edx),%al
  800aff:	74 f4                	je     800af5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b01:	0f b6 c0             	movzbl %al,%eax
  800b04:	0f b6 12             	movzbl (%edx),%edx
  800b07:	29 d0                	sub    %edx,%eax
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	53                   	push   %ebx
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b18:	eb 03                	jmp    800b1d <strncmp+0x12>
		n--, p++, q++;
  800b1a:	4a                   	dec    %edx
  800b1b:	40                   	inc    %eax
  800b1c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b1d:	85 d2                	test   %edx,%edx
  800b1f:	74 14                	je     800b35 <strncmp+0x2a>
  800b21:	8a 18                	mov    (%eax),%bl
  800b23:	84 db                	test   %bl,%bl
  800b25:	74 04                	je     800b2b <strncmp+0x20>
  800b27:	3a 19                	cmp    (%ecx),%bl
  800b29:	74 ef                	je     800b1a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2b:	0f b6 00             	movzbl (%eax),%eax
  800b2e:	0f b6 11             	movzbl (%ecx),%edx
  800b31:	29 d0                	sub    %edx,%eax
  800b33:	eb 05                	jmp    800b3a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b46:	eb 05                	jmp    800b4d <strchr+0x10>
		if (*s == c)
  800b48:	38 ca                	cmp    %cl,%dl
  800b4a:	74 0c                	je     800b58 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4c:	40                   	inc    %eax
  800b4d:	8a 10                	mov    (%eax),%dl
  800b4f:	84 d2                	test   %dl,%dl
  800b51:	75 f5                	jne    800b48 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b63:	eb 05                	jmp    800b6a <strfind+0x10>
		if (*s == c)
  800b65:	38 ca                	cmp    %cl,%dl
  800b67:	74 07                	je     800b70 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b69:	40                   	inc    %eax
  800b6a:	8a 10                	mov    (%eax),%dl
  800b6c:	84 d2                	test   %dl,%dl
  800b6e:	75 f5                	jne    800b65 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b81:	85 c9                	test   %ecx,%ecx
  800b83:	74 30                	je     800bb5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b85:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8b:	75 25                	jne    800bb2 <memset+0x40>
  800b8d:	f6 c1 03             	test   $0x3,%cl
  800b90:	75 20                	jne    800bb2 <memset+0x40>
		c &= 0xFF;
  800b92:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	c1 e3 08             	shl    $0x8,%ebx
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	c1 e6 18             	shl    $0x18,%esi
  800b9f:	89 d0                	mov    %edx,%eax
  800ba1:	c1 e0 10             	shl    $0x10,%eax
  800ba4:	09 f0                	or     %esi,%eax
  800ba6:	09 d0                	or     %edx,%eax
  800ba8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800baa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bad:	fc                   	cld    
  800bae:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb0:	eb 03                	jmp    800bb5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb2:	fc                   	cld    
  800bb3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb5:	89 f8                	mov    %edi,%eax
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bca:	39 c6                	cmp    %eax,%esi
  800bcc:	73 34                	jae    800c02 <memmove+0x46>
  800bce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd1:	39 d0                	cmp    %edx,%eax
  800bd3:	73 2d                	jae    800c02 <memmove+0x46>
		s += n;
		d += n;
  800bd5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd8:	f6 c2 03             	test   $0x3,%dl
  800bdb:	75 1b                	jne    800bf8 <memmove+0x3c>
  800bdd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be3:	75 13                	jne    800bf8 <memmove+0x3c>
  800be5:	f6 c1 03             	test   $0x3,%cl
  800be8:	75 0e                	jne    800bf8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bea:	83 ef 04             	sub    $0x4,%edi
  800bed:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bf3:	fd                   	std    
  800bf4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf6:	eb 07                	jmp    800bff <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf8:	4f                   	dec    %edi
  800bf9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bfc:	fd                   	std    
  800bfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bff:	fc                   	cld    
  800c00:	eb 20                	jmp    800c22 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c08:	75 13                	jne    800c1d <memmove+0x61>
  800c0a:	a8 03                	test   $0x3,%al
  800c0c:	75 0f                	jne    800c1d <memmove+0x61>
  800c0e:	f6 c1 03             	test   $0x3,%cl
  800c11:	75 0a                	jne    800c1d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c13:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c16:	89 c7                	mov    %eax,%edi
  800c18:	fc                   	cld    
  800c19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1b:	eb 05                	jmp    800c22 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c1d:	89 c7                	mov    %eax,%edi
  800c1f:	fc                   	cld    
  800c20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	89 04 24             	mov    %eax,(%esp)
  800c40:	e8 77 ff ff ff       	call   800bbc <memmove>
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c56:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5b:	eb 16                	jmp    800c73 <memcmp+0x2c>
		if (*s1 != *s2)
  800c5d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c60:	42                   	inc    %edx
  800c61:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c65:	38 c8                	cmp    %cl,%al
  800c67:	74 0a                	je     800c73 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c69:	0f b6 c0             	movzbl %al,%eax
  800c6c:	0f b6 c9             	movzbl %cl,%ecx
  800c6f:	29 c8                	sub    %ecx,%eax
  800c71:	eb 09                	jmp    800c7c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c73:	39 da                	cmp    %ebx,%edx
  800c75:	75 e6                	jne    800c5d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c8a:	89 c2                	mov    %eax,%edx
  800c8c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c8f:	eb 05                	jmp    800c96 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c91:	38 08                	cmp    %cl,(%eax)
  800c93:	74 05                	je     800c9a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c95:	40                   	inc    %eax
  800c96:	39 d0                	cmp    %edx,%eax
  800c98:	72 f7                	jb     800c91 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca8:	eb 01                	jmp    800cab <strtol+0xf>
		s++;
  800caa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cab:	8a 02                	mov    (%edx),%al
  800cad:	3c 20                	cmp    $0x20,%al
  800caf:	74 f9                	je     800caa <strtol+0xe>
  800cb1:	3c 09                	cmp    $0x9,%al
  800cb3:	74 f5                	je     800caa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb5:	3c 2b                	cmp    $0x2b,%al
  800cb7:	75 08                	jne    800cc1 <strtol+0x25>
		s++;
  800cb9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cba:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbf:	eb 13                	jmp    800cd4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc1:	3c 2d                	cmp    $0x2d,%al
  800cc3:	75 0a                	jne    800ccf <strtol+0x33>
		s++, neg = 1;
  800cc5:	8d 52 01             	lea    0x1(%edx),%edx
  800cc8:	bf 01 00 00 00       	mov    $0x1,%edi
  800ccd:	eb 05                	jmp    800cd4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ccf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd4:	85 db                	test   %ebx,%ebx
  800cd6:	74 05                	je     800cdd <strtol+0x41>
  800cd8:	83 fb 10             	cmp    $0x10,%ebx
  800cdb:	75 28                	jne    800d05 <strtol+0x69>
  800cdd:	8a 02                	mov    (%edx),%al
  800cdf:	3c 30                	cmp    $0x30,%al
  800ce1:	75 10                	jne    800cf3 <strtol+0x57>
  800ce3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ce7:	75 0a                	jne    800cf3 <strtol+0x57>
		s += 2, base = 16;
  800ce9:	83 c2 02             	add    $0x2,%edx
  800cec:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf1:	eb 12                	jmp    800d05 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	75 0e                	jne    800d05 <strtol+0x69>
  800cf7:	3c 30                	cmp    $0x30,%al
  800cf9:	75 05                	jne    800d00 <strtol+0x64>
		s++, base = 8;
  800cfb:	42                   	inc    %edx
  800cfc:	b3 08                	mov    $0x8,%bl
  800cfe:	eb 05                	jmp    800d05 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d00:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d0c:	8a 0a                	mov    (%edx),%cl
  800d0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d11:	80 fb 09             	cmp    $0x9,%bl
  800d14:	77 08                	ja     800d1e <strtol+0x82>
			dig = *s - '0';
  800d16:	0f be c9             	movsbl %cl,%ecx
  800d19:	83 e9 30             	sub    $0x30,%ecx
  800d1c:	eb 1e                	jmp    800d3c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d21:	80 fb 19             	cmp    $0x19,%bl
  800d24:	77 08                	ja     800d2e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d26:	0f be c9             	movsbl %cl,%ecx
  800d29:	83 e9 57             	sub    $0x57,%ecx
  800d2c:	eb 0e                	jmp    800d3c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d31:	80 fb 19             	cmp    $0x19,%bl
  800d34:	77 12                	ja     800d48 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d36:	0f be c9             	movsbl %cl,%ecx
  800d39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d3c:	39 f1                	cmp    %esi,%ecx
  800d3e:	7d 0c                	jge    800d4c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d40:	42                   	inc    %edx
  800d41:	0f af c6             	imul   %esi,%eax
  800d44:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d46:	eb c4                	jmp    800d0c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d48:	89 c1                	mov    %eax,%ecx
  800d4a:	eb 02                	jmp    800d4e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d4c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d52:	74 05                	je     800d59 <strtol+0xbd>
		*endptr = (char *) s;
  800d54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d57:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d59:	85 ff                	test   %edi,%edi
  800d5b:	74 04                	je     800d61 <strtol+0xc5>
  800d5d:	89 c8                	mov    %ecx,%eax
  800d5f:	f7 d8                	neg    %eax
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
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
