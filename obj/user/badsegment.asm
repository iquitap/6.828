
obj/user/badsegment：     文件格式 elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  80004e:	e8 e4 00 00 00       	call   800137 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	29 d0                	sub    %edx,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x39>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007d:	89 34 24             	mov    %esi,(%esp)
  800080:	e8 af ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    
  800091:	00 00                	add    %al,(%eax)
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 3f 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 28                	jle    80012f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800112:	00 
  800113:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80012a:	e8 5d 02 00 00       	call   80038c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	83 c4 2c             	add    $0x2c,%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 02 00 00 00       	mov    $0x2,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_yield>:

void
sys_yield(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 0a 00 00 00       	mov    $0xa,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017e:	be 00 00 00 00       	mov    $0x0,%esi
  800183:	b8 04 00 00 00       	mov    $0x4,%eax
  800188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 f7                	mov    %esi,%edi
  800193:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800195:	85 c0                	test   %eax,%eax
  800197:	7e 28                	jle    8001c1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800199:	89 44 24 10          	mov    %eax,0x10(%esp)
  80019d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001bc:	e8 cb 01 00 00       	call   80038c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	83 c4 2c             	add    $0x2c,%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 28                	jle    800214 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001ff:	00 
  800200:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800207:	00 
  800208:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80020f:	e8 78 01 00 00       	call   80038c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800214:	83 c4 2c             	add    $0x2c,%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 06 00 00 00       	mov    $0x6,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 28                	jle    800267 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800243:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024a:	00 
  80024b:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800262:	e8 25 01 00 00       	call   80038c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800267:	83 c4 2c             	add    $0x2c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 28                	jle    8002ba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	89 44 24 10          	mov    %eax,0x10(%esp)
  800296:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80029d:	00 
  80029e:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002b5:	e8 d2 00 00 00       	call   80038c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ba:	83 c4 2c             	add    $0x2c,%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 df                	mov    %ebx,%edi
  8002dd:	89 de                	mov    %ebx,%esi
  8002df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	7e 28                	jle    80030d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800300:	00 
  800301:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800308:	e8 7f 00 00 00       	call   80038c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030d:	83 c4 2c             	add    $0x2c,%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	b8 0b 00 00 00       	mov    $0xb,%eax
  800325:	8b 7d 14             	mov    0x14(%ebp),%edi
  800328:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
  800346:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034b:	8b 55 08             	mov    0x8(%ebp),%edx
  80034e:	89 cb                	mov    %ecx,%ebx
  800350:	89 cf                	mov    %ecx,%edi
  800352:	89 ce                	mov    %ecx,%esi
  800354:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	7e 28                	jle    800382 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800365:	00 
  800366:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80037d:	e8 0a 00 00 00       	call   80038c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800382:	83 c4 2c             	add    $0x2c,%esp
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    
	...

0080038c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800394:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800397:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80039d:	e8 95 fd ff ff       	call   800137 <sys_getenvid>
  8003a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003bf:	e8 c0 00 00 00       	call   800484 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 50 00 00 00       	call   800423 <vcprintf>
	cprintf("\n");
  8003d3:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003da:	e8 a5 00 00 00       	call   800484 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003df:	cc                   	int3   
  8003e0:	eb fd                	jmp    8003df <_panic+0x53>
	...

008003e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 14             	sub    $0x14,%esp
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ee:	8b 03                	mov    (%ebx),%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f7:	40                   	inc    %eax
  8003f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ff:	75 19                	jne    80041a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800401:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800408:	00 
  800409:	8d 43 08             	lea    0x8(%ebx),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 94 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041a:	ff 43 04             	incl   0x4(%ebx)
}
  80041d:	83 c4 14             	add    $0x14,%esp
  800420:	5b                   	pop    %ebx
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800433:	00 00 00 
	b.cnt = 0;
  800436:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  80045f:	e8 82 01 00 00       	call   8005e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800464:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	e8 2c fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80047c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 87 ff ff ff       	call   800423 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
	...

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	75 08                	jne    8004cc <printnum+0x2c>
  8004c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004ca:	77 57                	ja     800523 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d0:	4b                   	dec    %ebx
  8004d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004eb:	00 
  8004ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f9:	e8 56 08 00 00       	call   800d54 <__udivdi3>
  8004fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800502:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050d:	89 fa                	mov    %edi,%edx
  80050f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800512:	e8 89 ff ff ff       	call   8004a0 <printnum>
  800517:	eb 0f                	jmp    800528 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051d:	89 34 24             	mov    %esi,(%esp)
  800520:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800528:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800530:	8b 45 10             	mov    0x10(%ebp),%eax
  800533:	89 44 24 08          	mov    %eax,0x8(%esp)
  800537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053e:	00 
  80053f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	e8 23 09 00 00       	call   800e74 <__umoddi3>
  800551:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800555:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800562:	83 c4 3c             	add    $0x3c,%esp
  800565:	5b                   	pop    %ebx
  800566:	5e                   	pop    %esi
  800567:	5f                   	pop    %edi
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80056d:	83 fa 01             	cmp    $0x1,%edx
  800570:	7e 0e                	jle    800580 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800572:	8b 10                	mov    (%eax),%edx
  800574:	8d 4a 08             	lea    0x8(%edx),%ecx
  800577:	89 08                	mov    %ecx,(%eax)
  800579:	8b 02                	mov    (%edx),%eax
  80057b:	8b 52 04             	mov    0x4(%edx),%edx
  80057e:	eb 22                	jmp    8005a2 <getuint+0x38>
	else if (lflag)
  800580:	85 d2                	test   %edx,%edx
  800582:	74 10                	je     800594 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800584:	8b 10                	mov    (%eax),%edx
  800586:	8d 4a 04             	lea    0x4(%edx),%ecx
  800589:	89 08                	mov    %ecx,(%eax)
  80058b:	8b 02                	mov    (%edx),%eax
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	eb 0e                	jmp    8005a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8d 4a 04             	lea    0x4(%edx),%ecx
  800599:	89 08                	mov    %ecx,(%eax)
  80059b:	8b 02                	mov    (%edx),%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a2:	5d                   	pop    %ebp
  8005a3:	c3                   	ret    

008005a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b2:	73 08                	jae    8005bc <sprintputch+0x18>
		*b->buf++ = ch;
  8005b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b7:	88 0a                	mov    %cl,(%edx)
  8005b9:	42                   	inc    %edx
  8005ba:	89 10                	mov    %edx,(%eax)
}
  8005bc:	5d                   	pop    %ebp
  8005bd:	c3                   	ret    

008005be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 02 00 00 00       	call   8005e6 <vprintfmt>
	va_end(ap);
}
  8005e4:	c9                   	leave  
  8005e5:	c3                   	ret    

008005e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e6:	55                   	push   %ebp
  8005e7:	89 e5                	mov    %esp,%ebp
  8005e9:	57                   	push   %edi
  8005ea:	56                   	push   %esi
  8005eb:	53                   	push   %ebx
  8005ec:	83 ec 4c             	sub    $0x4c,%esp
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f5:	eb 12                	jmp    800609 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	0f 84 6b 03 00 00    	je     80096a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800609:	0f b6 06             	movzbl (%esi),%eax
  80060c:	46                   	inc    %esi
  80060d:	83 f8 25             	cmp    $0x25,%eax
  800610:	75 e5                	jne    8005f7 <vprintfmt+0x11>
  800612:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800616:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80061d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800622:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800633:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800637:	eb 1d                	jmp    800656 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80063c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800640:	eb 14                	jmp    800656 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800645:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80064c:	eb 08                	jmp    800656 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80064e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800651:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	0f b6 06             	movzbl (%esi),%eax
  800659:	8d 56 01             	lea    0x1(%esi),%edx
  80065c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065f:	8a 16                	mov    (%esi),%dl
  800661:	83 ea 23             	sub    $0x23,%edx
  800664:	80 fa 55             	cmp    $0x55,%dl
  800667:	0f 87 e1 02 00 00    	ja     80094e <vprintfmt+0x368>
  80066d:	0f b6 d2             	movzbl %dl,%edx
  800670:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800682:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800686:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800689:	8d 50 d0             	lea    -0x30(%eax),%edx
  80068c:	83 fa 09             	cmp    $0x9,%edx
  80068f:	77 2a                	ja     8006bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800691:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800692:	eb eb                	jmp    80067f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006a2:	eb 17                	jmp    8006bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a8:	78 98                	js     800642 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ad:	eb a7                	jmp    800656 <vprintfmt+0x70>
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b9:	eb 9b                	jmp    800656 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bf:	79 95                	jns    800656 <vprintfmt+0x70>
  8006c1:	eb 8b                	jmp    80064e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c7:	eb 8d                	jmp    800656 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e1:	e9 23 ff ff ff       	jmp    800609 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	79 02                	jns    8006f7 <vprintfmt+0x111>
  8006f5:	f7 d8                	neg    %eax
  8006f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f9:	83 f8 09             	cmp    $0x9,%eax
  8006fc:	7f 0b                	jg     800709 <vprintfmt+0x123>
  8006fe:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800705:	85 c0                	test   %eax,%eax
  800707:	75 23                	jne    80072c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800709:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070d:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800714:	00 
  800715:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	e8 9a fe ff ff       	call   8005be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800727:	e9 dd fe ff ff       	jmp    800609 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80072c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800730:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  800737:	00 
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
  80073f:	89 14 24             	mov    %edx,(%esp)
  800742:	e8 77 fe ff ff       	call   8005be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074a:	e9 ba fe ff ff       	jmp    800609 <vprintfmt+0x23>
  80074f:	89 f9                	mov    %edi,%ecx
  800751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800754:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)
  800760:	8b 30                	mov    (%eax),%esi
  800762:	85 f6                	test   %esi,%esi
  800764:	75 05                	jne    80076b <vprintfmt+0x185>
				p = "(null)";
  800766:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  80076b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076f:	0f 8e 84 00 00 00    	jle    8007f9 <vprintfmt+0x213>
  800775:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800779:	74 7e                	je     8007f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077f:	89 34 24             	mov    %esi,(%esp)
  800782:	e8 8b 02 00 00       	call   800a12 <strnlen>
  800787:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078a:	29 c2                	sub    %eax,%edx
  80078c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80078f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800793:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800796:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800799:	89 de                	mov    %ebx,%esi
  80079b:	89 d3                	mov    %edx,%ebx
  80079d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	eb 0b                	jmp    8007ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a5:	89 3c 24             	mov    %edi,(%esp)
  8007a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ab:	4b                   	dec    %ebx
  8007ac:	85 db                	test   %ebx,%ebx
  8007ae:	7f f1                	jg     8007a1 <vprintfmt+0x1bb>
  8007b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b3:	89 f3                	mov    %esi,%ebx
  8007b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	79 05                	jns    8007c4 <vprintfmt+0x1de>
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c7:	29 c2                	sub    %eax,%edx
  8007c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007cc:	eb 2b                	jmp    8007f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d2:	74 18                	je     8007ec <vprintfmt+0x206>
  8007d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007d7:	83 fa 5e             	cmp    $0x5e,%edx
  8007da:	76 10                	jbe    8007ec <vprintfmt+0x206>
					putch('?', putdat);
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
  8007ea:	eb 0a                	jmp    8007f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f9:	0f be 06             	movsbl (%esi),%eax
  8007fc:	46                   	inc    %esi
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 21                	je     800822 <vprintfmt+0x23c>
  800801:	85 ff                	test   %edi,%edi
  800803:	78 c9                	js     8007ce <vprintfmt+0x1e8>
  800805:	4f                   	dec    %edi
  800806:	79 c6                	jns    8007ce <vprintfmt+0x1e8>
  800808:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080b:	89 de                	mov    %ebx,%esi
  80080d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800810:	eb 18                	jmp    80082a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800812:	89 74 24 04          	mov    %esi,0x4(%esp)
  800816:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80081d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081f:	4b                   	dec    %ebx
  800820:	eb 08                	jmp    80082a <vprintfmt+0x244>
  800822:	8b 7d 08             	mov    0x8(%ebp),%edi
  800825:	89 de                	mov    %ebx,%esi
  800827:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80082a:	85 db                	test   %ebx,%ebx
  80082c:	7f e4                	jg     800812 <vprintfmt+0x22c>
  80082e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800831:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800833:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800836:	e9 ce fd ff ff       	jmp    800609 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083b:	83 f9 01             	cmp    $0x1,%ecx
  80083e:	7e 10                	jle    800850 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8d 50 08             	lea    0x8(%eax),%edx
  800846:	89 55 14             	mov    %edx,0x14(%ebp)
  800849:	8b 30                	mov    (%eax),%esi
  80084b:	8b 78 04             	mov    0x4(%eax),%edi
  80084e:	eb 26                	jmp    800876 <vprintfmt+0x290>
	else if (lflag)
  800850:	85 c9                	test   %ecx,%ecx
  800852:	74 12                	je     800866 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 30                	mov    (%eax),%esi
  80085f:	89 f7                	mov    %esi,%edi
  800861:	c1 ff 1f             	sar    $0x1f,%edi
  800864:	eb 10                	jmp    800876 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 30                	mov    (%eax),%esi
  800871:	89 f7                	mov    %esi,%edi
  800873:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800876:	85 ff                	test   %edi,%edi
  800878:	78 0a                	js     800884 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80087a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087f:	e9 8c 00 00 00       	jmp    800910 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800884:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800888:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800892:	f7 de                	neg    %esi
  800894:	83 d7 00             	adc    $0x0,%edi
  800897:	f7 df                	neg    %edi
			}
			base = 10;
  800899:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089e:	eb 70                	jmp    800910 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a0:	89 ca                	mov    %ecx,%edx
  8008a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a5:	e8 c0 fc ff ff       	call   80056a <getuint>
  8008aa:	89 c6                	mov    %eax,%esi
  8008ac:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008b3:	eb 5b                	jmp    800910 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8008b5:	89 ca                	mov    %ecx,%edx
  8008b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ba:	e8 ab fc ff ff       	call   80056a <getuint>
  8008bf:	89 c6                	mov    %eax,%esi
  8008c1:	89 d7                	mov    %edx,%edi
                        base = 8;
  8008c3:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8008c8:	eb 46                	jmp    800910 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8008ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8d 50 04             	lea    0x4(%eax),%edx
  8008ec:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ef:	8b 30                	mov    (%eax),%esi
  8008f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008fb:	eb 13                	jmp    800910 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008fd:	89 ca                	mov    %ecx,%edx
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800902:	e8 63 fc ff ff       	call   80056a <getuint>
  800907:	89 c6                	mov    %eax,%esi
  800909:	89 d7                	mov    %edx,%edi
			base = 16;
  80090b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800910:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800914:	89 54 24 10          	mov    %edx,0x10(%esp)
  800918:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80091b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80091f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800923:	89 34 24             	mov    %esi,(%esp)
  800926:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092a:	89 da                	mov    %ebx,%edx
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	e8 6c fb ff ff       	call   8004a0 <printnum>
			break;
  800934:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800937:	e9 cd fc ff ff       	jmp    800609 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80093c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800940:	89 04 24             	mov    %eax,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800946:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800949:	e9 bb fc ff ff       	jmp    800609 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80094e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800952:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800959:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095c:	eb 01                	jmp    80095f <vprintfmt+0x379>
  80095e:	4e                   	dec    %esi
  80095f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800963:	75 f9                	jne    80095e <vprintfmt+0x378>
  800965:	e9 9f fc ff ff       	jmp    800609 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80096a:	83 c4 4c             	add    $0x4c,%esp
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	83 ec 28             	sub    $0x28,%esp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800981:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800985:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800988:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098f:	85 c0                	test   %eax,%eax
  800991:	74 30                	je     8009c3 <vsnprintf+0x51>
  800993:	85 d2                	test   %edx,%edx
  800995:	7e 33                	jle    8009ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099e:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ac:	c7 04 24 a4 05 80 00 	movl   $0x8005a4,(%esp)
  8009b3:	e8 2e fc ff ff       	call   8005e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c1:	eb 0c                	jmp    8009cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c8:	eb 05                	jmp    8009cf <vsnprintf+0x5d>
  8009ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	89 04 24             	mov    %eax,(%esp)
  8009f2:	e8 7b ff ff ff       	call   800972 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    
  8009f9:	00 00                	add    %al,(%eax)
	...

008009fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
  800a07:	eb 01                	jmp    800a0a <strlen+0xe>
		n++;
  800a09:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0e:	75 f9                	jne    800a09 <strlen+0xd>
		n++;
	return n;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	eb 01                	jmp    800a23 <strnlen+0x11>
		n++;
  800a22:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a23:	39 d0                	cmp    %edx,%eax
  800a25:	74 06                	je     800a2d <strnlen+0x1b>
  800a27:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2b:	75 f5                	jne    800a22 <strnlen+0x10>
		n++;
	return n;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a41:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a44:	42                   	inc    %edx
  800a45:	84 c9                	test   %cl,%cl
  800a47:	75 f5                	jne    800a3e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 08             	sub    $0x8,%esp
  800a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a56:	89 1c 24             	mov    %ebx,(%esp)
  800a59:	e8 9e ff ff ff       	call   8009fc <strlen>
	strcpy(dst + len, src);
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a65:	01 d8                	add    %ebx,%eax
  800a67:	89 04 24             	mov    %eax,(%esp)
  800a6a:	e8 c0 ff ff ff       	call   800a2f <strcpy>
	return dst;
}
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	83 c4 08             	add    $0x8,%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a82:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	eb 0c                	jmp    800a98 <strncpy+0x21>
		*dst++ = *src;
  800a8c:	8a 1a                	mov    (%edx),%bl
  800a8e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a91:	80 3a 01             	cmpb   $0x1,(%edx)
  800a94:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a97:	41                   	inc    %ecx
  800a98:	39 f1                	cmp    %esi,%ecx
  800a9a:	75 f0                	jne    800a8c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aae:	85 d2                	test   %edx,%edx
  800ab0:	75 0a                	jne    800abc <strlcpy+0x1c>
  800ab2:	89 f0                	mov    %esi,%eax
  800ab4:	eb 1a                	jmp    800ad0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab6:	88 18                	mov    %bl,(%eax)
  800ab8:	40                   	inc    %eax
  800ab9:	41                   	inc    %ecx
  800aba:	eb 02                	jmp    800abe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800abe:	4a                   	dec    %edx
  800abf:	74 0a                	je     800acb <strlcpy+0x2b>
  800ac1:	8a 19                	mov    (%ecx),%bl
  800ac3:	84 db                	test   %bl,%bl
  800ac5:	75 ef                	jne    800ab6 <strlcpy+0x16>
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	eb 02                	jmp    800acd <strlcpy+0x2d>
  800acb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800acd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ad0:	29 f0                	sub    %esi,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adf:	eb 02                	jmp    800ae3 <strcmp+0xd>
		p++, q++;
  800ae1:	41                   	inc    %ecx
  800ae2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae3:	8a 01                	mov    (%ecx),%al
  800ae5:	84 c0                	test   %al,%al
  800ae7:	74 04                	je     800aed <strcmp+0x17>
  800ae9:	3a 02                	cmp    (%edx),%al
  800aeb:	74 f4                	je     800ae1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aed:	0f b6 c0             	movzbl %al,%eax
  800af0:	0f b6 12             	movzbl (%edx),%edx
  800af3:	29 d0                	sub    %edx,%eax
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b04:	eb 03                	jmp    800b09 <strncmp+0x12>
		n--, p++, q++;
  800b06:	4a                   	dec    %edx
  800b07:	40                   	inc    %eax
  800b08:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b09:	85 d2                	test   %edx,%edx
  800b0b:	74 14                	je     800b21 <strncmp+0x2a>
  800b0d:	8a 18                	mov    (%eax),%bl
  800b0f:	84 db                	test   %bl,%bl
  800b11:	74 04                	je     800b17 <strncmp+0x20>
  800b13:	3a 19                	cmp    (%ecx),%bl
  800b15:	74 ef                	je     800b06 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b17:	0f b6 00             	movzbl (%eax),%eax
  800b1a:	0f b6 11             	movzbl (%ecx),%edx
  800b1d:	29 d0                	sub    %edx,%eax
  800b1f:	eb 05                	jmp    800b26 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b32:	eb 05                	jmp    800b39 <strchr+0x10>
		if (*s == c)
  800b34:	38 ca                	cmp    %cl,%dl
  800b36:	74 0c                	je     800b44 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b38:	40                   	inc    %eax
  800b39:	8a 10                	mov    (%eax),%dl
  800b3b:	84 d2                	test   %dl,%dl
  800b3d:	75 f5                	jne    800b34 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b4f:	eb 05                	jmp    800b56 <strfind+0x10>
		if (*s == c)
  800b51:	38 ca                	cmp    %cl,%dl
  800b53:	74 07                	je     800b5c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b55:	40                   	inc    %eax
  800b56:	8a 10                	mov    (%eax),%dl
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	75 f5                	jne    800b51 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b6d:	85 c9                	test   %ecx,%ecx
  800b6f:	74 30                	je     800ba1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b77:	75 25                	jne    800b9e <memset+0x40>
  800b79:	f6 c1 03             	test   $0x3,%cl
  800b7c:	75 20                	jne    800b9e <memset+0x40>
		c &= 0xFF;
  800b7e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b81:	89 d3                	mov    %edx,%ebx
  800b83:	c1 e3 08             	shl    $0x8,%ebx
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	c1 e6 18             	shl    $0x18,%esi
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	c1 e0 10             	shl    $0x10,%eax
  800b90:	09 f0                	or     %esi,%eax
  800b92:	09 d0                	or     %edx,%eax
  800b94:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b96:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b99:	fc                   	cld    
  800b9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9c:	eb 03                	jmp    800ba1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9e:	fc                   	cld    
  800b9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba1:	89 f8                	mov    %edi,%eax
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb6:	39 c6                	cmp    %eax,%esi
  800bb8:	73 34                	jae    800bee <memmove+0x46>
  800bba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bbd:	39 d0                	cmp    %edx,%eax
  800bbf:	73 2d                	jae    800bee <memmove+0x46>
		s += n;
		d += n;
  800bc1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc4:	f6 c2 03             	test   $0x3,%dl
  800bc7:	75 1b                	jne    800be4 <memmove+0x3c>
  800bc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcf:	75 13                	jne    800be4 <memmove+0x3c>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0e                	jne    800be4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd6:	83 ef 04             	sub    $0x4,%edi
  800bd9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bdf:	fd                   	std    
  800be0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be2:	eb 07                	jmp    800beb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be4:	4f                   	dec    %edi
  800be5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800be8:	fd                   	std    
  800be9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800beb:	fc                   	cld    
  800bec:	eb 20                	jmp    800c0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf4:	75 13                	jne    800c09 <memmove+0x61>
  800bf6:	a8 03                	test   $0x3,%al
  800bf8:	75 0f                	jne    800c09 <memmove+0x61>
  800bfa:	f6 c1 03             	test   $0x3,%cl
  800bfd:	75 0a                	jne    800c09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	fc                   	cld    
  800c05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c07:	eb 05                	jmp    800c0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	fc                   	cld    
  800c0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c18:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	89 04 24             	mov    %eax,(%esp)
  800c2c:	e8 77 ff ff ff       	call   800ba8 <memmove>
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c42:	ba 00 00 00 00       	mov    $0x0,%edx
  800c47:	eb 16                	jmp    800c5f <memcmp+0x2c>
		if (*s1 != *s2)
  800c49:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c4c:	42                   	inc    %edx
  800c4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c51:	38 c8                	cmp    %cl,%al
  800c53:	74 0a                	je     800c5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c55:	0f b6 c0             	movzbl %al,%eax
  800c58:	0f b6 c9             	movzbl %cl,%ecx
  800c5b:	29 c8                	sub    %ecx,%eax
  800c5d:	eb 09                	jmp    800c68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5f:	39 da                	cmp    %ebx,%edx
  800c61:	75 e6                	jne    800c49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c76:	89 c2                	mov    %eax,%edx
  800c78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c7b:	eb 05                	jmp    800c82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7d:	38 08                	cmp    %cl,(%eax)
  800c7f:	74 05                	je     800c86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c81:	40                   	inc    %eax
  800c82:	39 d0                	cmp    %edx,%eax
  800c84:	72 f7                	jb     800c7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c94:	eb 01                	jmp    800c97 <strtol+0xf>
		s++;
  800c96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c97:	8a 02                	mov    (%edx),%al
  800c99:	3c 20                	cmp    $0x20,%al
  800c9b:	74 f9                	je     800c96 <strtol+0xe>
  800c9d:	3c 09                	cmp    $0x9,%al
  800c9f:	74 f5                	je     800c96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca1:	3c 2b                	cmp    $0x2b,%al
  800ca3:	75 08                	jne    800cad <strtol+0x25>
		s++;
  800ca5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	eb 13                	jmp    800cc0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cad:	3c 2d                	cmp    $0x2d,%al
  800caf:	75 0a                	jne    800cbb <strtol+0x33>
		s++, neg = 1;
  800cb1:	8d 52 01             	lea    0x1(%edx),%edx
  800cb4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb9:	eb 05                	jmp    800cc0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc0:	85 db                	test   %ebx,%ebx
  800cc2:	74 05                	je     800cc9 <strtol+0x41>
  800cc4:	83 fb 10             	cmp    $0x10,%ebx
  800cc7:	75 28                	jne    800cf1 <strtol+0x69>
  800cc9:	8a 02                	mov    (%edx),%al
  800ccb:	3c 30                	cmp    $0x30,%al
  800ccd:	75 10                	jne    800cdf <strtol+0x57>
  800ccf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cd3:	75 0a                	jne    800cdf <strtol+0x57>
		s += 2, base = 16;
  800cd5:	83 c2 02             	add    $0x2,%edx
  800cd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cdd:	eb 12                	jmp    800cf1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cdf:	85 db                	test   %ebx,%ebx
  800ce1:	75 0e                	jne    800cf1 <strtol+0x69>
  800ce3:	3c 30                	cmp    $0x30,%al
  800ce5:	75 05                	jne    800cec <strtol+0x64>
		s++, base = 8;
  800ce7:	42                   	inc    %edx
  800ce8:	b3 08                	mov    $0x8,%bl
  800cea:	eb 05                	jmp    800cf1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf8:	8a 0a                	mov    (%edx),%cl
  800cfa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cfd:	80 fb 09             	cmp    $0x9,%bl
  800d00:	77 08                	ja     800d0a <strtol+0x82>
			dig = *s - '0';
  800d02:	0f be c9             	movsbl %cl,%ecx
  800d05:	83 e9 30             	sub    $0x30,%ecx
  800d08:	eb 1e                	jmp    800d28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d0d:	80 fb 19             	cmp    $0x19,%bl
  800d10:	77 08                	ja     800d1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d12:	0f be c9             	movsbl %cl,%ecx
  800d15:	83 e9 57             	sub    $0x57,%ecx
  800d18:	eb 0e                	jmp    800d28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d1d:	80 fb 19             	cmp    $0x19,%bl
  800d20:	77 12                	ja     800d34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d28:	39 f1                	cmp    %esi,%ecx
  800d2a:	7d 0c                	jge    800d38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d2c:	42                   	inc    %edx
  800d2d:	0f af c6             	imul   %esi,%eax
  800d30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d32:	eb c4                	jmp    800cf8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d34:	89 c1                	mov    %eax,%ecx
  800d36:	eb 02                	jmp    800d3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d3e:	74 05                	je     800d45 <strtol+0xbd>
		*endptr = (char *) s;
  800d40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d45:	85 ff                	test   %edi,%edi
  800d47:	74 04                	je     800d4d <strtol+0xc5>
  800d49:	89 c8                	mov    %ecx,%eax
  800d4b:	f7 d8                	neg    %eax
}
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
	...

00800d54 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d54:	55                   	push   %ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	83 ec 10             	sub    $0x10,%esp
  800d5a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d5e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d66:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d6a:	89 cd                	mov    %ecx,%ebp
  800d6c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	75 2c                	jne    800da0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d74:	39 f9                	cmp    %edi,%ecx
  800d76:	77 68                	ja     800de0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d78:	85 c9                	test   %ecx,%ecx
  800d7a:	75 0b                	jne    800d87 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d81:	31 d2                	xor    %edx,%edx
  800d83:	f7 f1                	div    %ecx
  800d85:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d87:	31 d2                	xor    %edx,%edx
  800d89:	89 f8                	mov    %edi,%eax
  800d8b:	f7 f1                	div    %ecx
  800d8d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d8f:	89 f0                	mov    %esi,%eax
  800d91:	f7 f1                	div    %ecx
  800d93:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d95:	89 f0                	mov    %esi,%eax
  800d97:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800da0:	39 f8                	cmp    %edi,%eax
  800da2:	77 2c                	ja     800dd0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800da4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800da7:	83 f6 1f             	xor    $0x1f,%esi
  800daa:	75 4c                	jne    800df8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dac:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dae:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db3:	72 0a                	jb     800dbf <__udivdi3+0x6b>
  800db5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800db9:	0f 87 ad 00 00 00    	ja     800e6c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dbf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc4:	89 f0                	mov    %esi,%eax
  800dc6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
  800dcf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dd0:	31 ff                	xor    %edi,%edi
  800dd2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd4:	89 f0                	mov    %esi,%eax
  800dd6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	89 f0                	mov    %esi,%eax
  800de4:	f7 f1                	div    %ecx
  800de6:	89 c6                	mov    %eax,%esi
  800de8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dea:	89 f0                	mov    %esi,%eax
  800dec:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800df8:	89 f1                	mov    %esi,%ecx
  800dfa:	d3 e0                	shl    %cl,%eax
  800dfc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e00:	b8 20 00 00 00       	mov    $0x20,%eax
  800e05:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e07:	89 ea                	mov    %ebp,%edx
  800e09:	88 c1                	mov    %al,%cl
  800e0b:	d3 ea                	shr    %cl,%edx
  800e0d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e11:	09 ca                	or     %ecx,%edx
  800e13:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e17:	89 f1                	mov    %esi,%ecx
  800e19:	d3 e5                	shl    %cl,%ebp
  800e1b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e1f:	89 fd                	mov    %edi,%ebp
  800e21:	88 c1                	mov    %al,%cl
  800e23:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e25:	89 fa                	mov    %edi,%edx
  800e27:	89 f1                	mov    %esi,%ecx
  800e29:	d3 e2                	shl    %cl,%edx
  800e2b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e2f:	88 c1                	mov    %al,%cl
  800e31:	d3 ef                	shr    %cl,%edi
  800e33:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e35:	89 f8                	mov    %edi,%eax
  800e37:	89 ea                	mov    %ebp,%edx
  800e39:	f7 74 24 08          	divl   0x8(%esp)
  800e3d:	89 d1                	mov    %edx,%ecx
  800e3f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e41:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e45:	39 d1                	cmp    %edx,%ecx
  800e47:	72 17                	jb     800e60 <__udivdi3+0x10c>
  800e49:	74 09                	je     800e54 <__udivdi3+0x100>
  800e4b:	89 fe                	mov    %edi,%esi
  800e4d:	31 ff                	xor    %edi,%edi
  800e4f:	e9 41 ff ff ff       	jmp    800d95 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e54:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e58:	89 f1                	mov    %esi,%ecx
  800e5a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e5c:	39 c2                	cmp    %eax,%edx
  800e5e:	73 eb                	jae    800e4b <__udivdi3+0xf7>
		{
		  q0--;
  800e60:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e63:	31 ff                	xor    %edi,%edi
  800e65:	e9 2b ff ff ff       	jmp    800d95 <__udivdi3+0x41>
  800e6a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e6c:	31 f6                	xor    %esi,%esi
  800e6e:	e9 22 ff ff ff       	jmp    800d95 <__udivdi3+0x41>
	...

00800e74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e74:	55                   	push   %ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	83 ec 20             	sub    $0x20,%esp
  800e7a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e7e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e82:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e86:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e8a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e92:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e94:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e96:	85 ed                	test   %ebp,%ebp
  800e98:	75 16                	jne    800eb0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e9a:	39 f1                	cmp    %esi,%ecx
  800e9c:	0f 86 a6 00 00 00    	jbe    800f48 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ea4:	89 d0                	mov    %edx,%eax
  800ea6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea8:	83 c4 20             	add    $0x20,%esp
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    
  800eaf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eb0:	39 f5                	cmp    %esi,%ebp
  800eb2:	0f 87 ac 00 00 00    	ja     800f64 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eb8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ebb:	83 f0 1f             	xor    $0x1f,%eax
  800ebe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec2:	0f 84 a8 00 00 00    	je     800f70 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ecc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ece:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ed7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e8                	shr    %cl,%eax
  800edf:	09 e8                	or     %ebp,%eax
  800ee1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800ee5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ee9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eed:	d3 e0                	shl    %cl,%eax
  800eef:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ef3:	89 f2                	mov    %esi,%edx
  800ef5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ef7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800efb:	d3 e0                	shl    %cl,%eax
  800efd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f01:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f0b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	f7 74 24 18          	divl   0x18(%esp)
  800f13:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f15:	f7 64 24 0c          	mull   0xc(%esp)
  800f19:	89 c5                	mov    %eax,%ebp
  800f1b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f1d:	39 d6                	cmp    %edx,%esi
  800f1f:	72 67                	jb     800f88 <__umoddi3+0x114>
  800f21:	74 75                	je     800f98 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f23:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f27:	29 e8                	sub    %ebp,%eax
  800f29:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f2b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f2f:	d3 e8                	shr    %cl,%eax
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f37:	09 d0                	or     %edx,%eax
  800f39:	89 f2                	mov    %esi,%edx
  800f3b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f41:	83 c4 20             	add    $0x20,%esp
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f48:	85 c9                	test   %ecx,%ecx
  800f4a:	75 0b                	jne    800f57 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f51:	31 d2                	xor    %edx,%edx
  800f53:	f7 f1                	div    %ecx
  800f55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f57:	89 f0                	mov    %esi,%eax
  800f59:	31 d2                	xor    %edx,%edx
  800f5b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	e9 3e ff ff ff       	jmp    800ea2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f64:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f70:	39 f5                	cmp    %esi,%ebp
  800f72:	72 04                	jb     800f78 <__umoddi3+0x104>
  800f74:	39 f9                	cmp    %edi,%ecx
  800f76:	77 06                	ja     800f7e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f78:	89 f2                	mov    %esi,%edx
  800f7a:	29 cf                	sub    %ecx,%edi
  800f7c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f7e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f88:	89 d1                	mov    %edx,%ecx
  800f8a:	89 c5                	mov    %eax,%ebp
  800f8c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f90:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f94:	eb 8d                	jmp    800f23 <__umoddi3+0xaf>
  800f96:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f98:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800f9c:	72 ea                	jb     800f88 <__umoddi3+0x114>
  800f9e:	89 f1                	mov    %esi,%ecx
  800fa0:	eb 81                	jmp    800f23 <__umoddi3+0xaf>
