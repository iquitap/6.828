
obj/user/faultwritekernel：     文件格式 elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  800052:	e8 e4 00 00 00       	call   80013b <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x39>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800081:	89 34 24             	mov    %esi,(%esp)
  800084:	e8 ab ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 3f 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 28                	jle    800133 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80012e:	e8 5d 02 00 00       	call   800390 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	83 c4 2c             	add    $0x2c,%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 28                	jle    8001c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001c0:	e8 cb 01 00 00       	call   800390 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	83 c4 2c             	add    $0x2c,%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 75 18             	mov    0x18(%ebp),%esi
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 28                	jle    800218 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800213:	e8 78 01 00 00       	call   800390 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800218:	83 c4 2c             	add    $0x2c,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	b8 06 00 00 00       	mov    $0x6,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7e 28                	jle    80026b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	89 44 24 10          	mov    %eax,0x10(%esp)
  800247:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024e:	00 
  80024f:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800266:	e8 25 01 00 00       	call   800390 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	83 c4 2c             	add    $0x2c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 28                	jle    8002be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002b9:	e8 d2 00 00 00       	call   800390 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002be:	83 c4 2c             	add    $0x2c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 df                	mov    %ebx,%edi
  8002e1:	89 de                	mov    %ebx,%esi
  8002e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	7e 28                	jle    800311 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80030c:	e8 7f 00 00 00       	call   800390 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	b8 0b 00 00 00       	mov    $0xb,%eax
  800329:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800332:	8b 55 08             	mov    0x8(%ebp),%edx
  800335:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 cb                	mov    %ecx,%ebx
  800354:	89 cf                	mov    %ecx,%edi
  800356:	89 ce                	mov    %ecx,%esi
  800358:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	7e 28                	jle    800386 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800369:	00 
  80036a:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800371:	00 
  800372:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800379:	00 
  80037a:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800381:	e8 0a 00 00 00       	call   800390 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800386:	83 c4 2c             	add    $0x2c,%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    
	...

00800390 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800398:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003a1:	e8 95 fd ff ff       	call   80013b <sys_getenvid>
  8003a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bc:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003c3:	e8 c0 00 00 00       	call   800488 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 50 00 00 00       	call   800427 <vcprintf>
	cprintf("\n");
  8003d7:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003de:	e8 a5 00 00 00       	call   800488 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e3:	cc                   	int3   
  8003e4:	eb fd                	jmp    8003e3 <_panic+0x53>
	...

008003e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	53                   	push   %ebx
  8003ec:	83 ec 14             	sub    $0x14,%esp
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f2:	8b 03                	mov    (%ebx),%eax
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003fb:	40                   	inc    %eax
  8003fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800403:	75 19                	jne    80041e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800405:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80040c:	00 
  80040d:	8d 43 08             	lea    0x8(%ebx),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 94 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800418:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041e:	ff 43 04             	incl   0x4(%ebx)
}
  800421:	83 c4 14             	add    $0x14,%esp
  800424:	5b                   	pop    %ebx
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800430:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800437:	00 00 00 
	b.cnt = 0;
  80043a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800441:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800444:	8b 45 0c             	mov    0xc(%ebp),%eax
  800447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800452:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	c7 04 24 e8 03 80 00 	movl   $0x8003e8,(%esp)
  800463:	e8 82 01 00 00       	call   8005ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800468:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800472:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 2c fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800480:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	e8 87 ff ff ff       	call   800427 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
	...

008004a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	57                   	push   %edi
  8004a8:	56                   	push   %esi
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 3c             	sub    $0x3c,%esp
  8004ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b0:	89 d7                	mov    %edx,%edi
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	75 08                	jne    8004d0 <printnum+0x2c>
  8004c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004ce:	77 57                	ja     800527 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d4:	4b                   	dec    %ebx
  8004d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ef:	00 
  8004f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fd:	e8 56 08 00 00       	call   800d58 <__udivdi3>
  800502:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800506:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050a:	89 04 24             	mov    %eax,(%esp)
  80050d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800511:	89 fa                	mov    %edi,%edx
  800513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800516:	e8 89 ff ff ff       	call   8004a4 <printnum>
  80051b:	eb 0f                	jmp    80052c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80051d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800521:	89 34 24             	mov    %esi,(%esp)
  800524:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800527:	4b                   	dec    %ebx
  800528:	85 db                	test   %ebx,%ebx
  80052a:	7f f1                	jg     80051d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80052c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800530:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800534:	8b 45 10             	mov    0x10(%ebp),%eax
  800537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800542:	00 
  800543:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800550:	e8 23 09 00 00       	call   800e78 <__umoddi3>
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800566:	83 c4 3c             	add    $0x3c,%esp
  800569:	5b                   	pop    %ebx
  80056a:	5e                   	pop    %esi
  80056b:	5f                   	pop    %edi
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800571:	83 fa 01             	cmp    $0x1,%edx
  800574:	7e 0e                	jle    800584 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800576:	8b 10                	mov    (%eax),%edx
  800578:	8d 4a 08             	lea    0x8(%edx),%ecx
  80057b:	89 08                	mov    %ecx,(%eax)
  80057d:	8b 02                	mov    (%edx),%eax
  80057f:	8b 52 04             	mov    0x4(%edx),%edx
  800582:	eb 22                	jmp    8005a6 <getuint+0x38>
	else if (lflag)
  800584:	85 d2                	test   %edx,%edx
  800586:	74 10                	je     800598 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80058d:	89 08                	mov    %ecx,(%eax)
  80058f:	8b 02                	mov    (%edx),%eax
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	eb 0e                	jmp    8005a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059d:	89 08                	mov    %ecx,(%eax)
  80059f:	8b 02                	mov    (%edx),%eax
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ae:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b6:	73 08                	jae    8005c0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005bb:	88 0a                	mov    %cl,(%edx)
  8005bd:	42                   	inc    %edx
  8005be:	89 10                	mov    %edx,(%eax)
}
  8005c0:	5d                   	pop    %ebp
  8005c1:	c3                   	ret    

008005c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	e8 02 00 00 00       	call   8005ea <vprintfmt>
	va_end(ap);
}
  8005e8:	c9                   	leave  
  8005e9:	c3                   	ret    

008005ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	57                   	push   %edi
  8005ee:	56                   	push   %esi
  8005ef:	53                   	push   %ebx
  8005f0:	83 ec 4c             	sub    $0x4c,%esp
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f9:	eb 12                	jmp    80060d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	0f 84 6b 03 00 00    	je     80096e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800603:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80060d:	0f b6 06             	movzbl (%esi),%eax
  800610:	46                   	inc    %esi
  800611:	83 f8 25             	cmp    $0x25,%eax
  800614:	75 e5                	jne    8005fb <vprintfmt+0x11>
  800616:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80061a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800621:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800626:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80062d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800632:	eb 26                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800637:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80063b:	eb 1d                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800640:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800644:	eb 14                	jmp    80065a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800649:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800650:	eb 08                	jmp    80065a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800652:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800655:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	0f b6 06             	movzbl (%esi),%eax
  80065d:	8d 56 01             	lea    0x1(%esi),%edx
  800660:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800663:	8a 16                	mov    (%esi),%dl
  800665:	83 ea 23             	sub    $0x23,%edx
  800668:	80 fa 55             	cmp    $0x55,%dl
  80066b:	0f 87 e1 02 00 00    	ja     800952 <vprintfmt+0x368>
  800671:	0f b6 d2             	movzbl %dl,%edx
  800674:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  80067b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800683:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800686:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80068a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80068d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800690:	83 fa 09             	cmp    $0x9,%edx
  800693:	77 2a                	ja     8006bf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800695:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800696:	eb eb                	jmp    800683 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006a6:	eb 17                	jmp    8006bf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ac:	78 98                	js     800646 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b1:	eb a7                	jmp    80065a <vprintfmt+0x70>
  8006b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006bd:	eb 9b                	jmp    80065a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c3:	79 95                	jns    80065a <vprintfmt+0x70>
  8006c5:	eb 8b                	jmp    800652 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006cb:	eb 8d                	jmp    80065a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 50 04             	lea    0x4(%eax),%edx
  8006d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e5:	e9 23 ff ff ff       	jmp    80060d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	79 02                	jns    8006fb <vprintfmt+0x111>
  8006f9:	f7 d8                	neg    %eax
  8006fb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006fd:	83 f8 09             	cmp    $0x9,%eax
  800700:	7f 0b                	jg     80070d <vprintfmt+0x123>
  800702:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800709:	85 c0                	test   %eax,%eax
  80070b:	75 23                	jne    800730 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80070d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800711:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800718:	00 
  800719:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 9a fe ff ff       	call   8005c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80072b:	e9 dd fe ff ff       	jmp    80060d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800734:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  80073b:	00 
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
  800743:	89 14 24             	mov    %edx,(%esp)
  800746:	e8 77 fe ff ff       	call   8005c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074e:	e9 ba fe ff ff       	jmp    80060d <vprintfmt+0x23>
  800753:	89 f9                	mov    %edi,%ecx
  800755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 30                	mov    (%eax),%esi
  800766:	85 f6                	test   %esi,%esi
  800768:	75 05                	jne    80076f <vprintfmt+0x185>
				p = "(null)";
  80076a:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  80076f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800773:	0f 8e 84 00 00 00    	jle    8007fd <vprintfmt+0x213>
  800779:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80077d:	74 7e                	je     8007fd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800783:	89 34 24             	mov    %esi,(%esp)
  800786:	e8 8b 02 00 00       	call   800a16 <strnlen>
  80078b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078e:	29 c2                	sub    %eax,%edx
  800790:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800793:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800797:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80079d:	89 de                	mov    %ebx,%esi
  80079f:	89 d3                	mov    %edx,%ebx
  8007a1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	eb 0b                	jmp    8007b0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	89 3c 24             	mov    %edi,(%esp)
  8007ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	4b                   	dec    %ebx
  8007b0:	85 db                	test   %ebx,%ebx
  8007b2:	7f f1                	jg     8007a5 <vprintfmt+0x1bb>
  8007b4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b7:	89 f3                	mov    %esi,%ebx
  8007b9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	79 05                	jns    8007c8 <vprintfmt+0x1de>
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cb:	29 c2                	sub    %eax,%edx
  8007cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d0:	eb 2b                	jmp    8007fd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d6:	74 18                	je     8007f0 <vprintfmt+0x206>
  8007d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007db:	83 fa 5e             	cmp    $0x5e,%edx
  8007de:	76 10                	jbe    8007f0 <vprintfmt+0x206>
					putch('?', putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007eb:	ff 55 08             	call   *0x8(%ebp)
  8007ee:	eb 0a                	jmp    8007fa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fa:	ff 4d e4             	decl   -0x1c(%ebp)
  8007fd:	0f be 06             	movsbl (%esi),%eax
  800800:	46                   	inc    %esi
  800801:	85 c0                	test   %eax,%eax
  800803:	74 21                	je     800826 <vprintfmt+0x23c>
  800805:	85 ff                	test   %edi,%edi
  800807:	78 c9                	js     8007d2 <vprintfmt+0x1e8>
  800809:	4f                   	dec    %edi
  80080a:	79 c6                	jns    8007d2 <vprintfmt+0x1e8>
  80080c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080f:	89 de                	mov    %ebx,%esi
  800811:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800814:	eb 18                	jmp    80082e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800821:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800823:	4b                   	dec    %ebx
  800824:	eb 08                	jmp    80082e <vprintfmt+0x244>
  800826:	8b 7d 08             	mov    0x8(%ebp),%edi
  800829:	89 de                	mov    %ebx,%esi
  80082b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80082e:	85 db                	test   %ebx,%ebx
  800830:	7f e4                	jg     800816 <vprintfmt+0x22c>
  800832:	89 7d 08             	mov    %edi,0x8(%ebp)
  800835:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80083a:	e9 ce fd ff ff       	jmp    80060d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083f:	83 f9 01             	cmp    $0x1,%ecx
  800842:	7e 10                	jle    800854 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 08             	lea    0x8(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	8b 30                	mov    (%eax),%esi
  80084f:	8b 78 04             	mov    0x4(%eax),%edi
  800852:	eb 26                	jmp    80087a <vprintfmt+0x290>
	else if (lflag)
  800854:	85 c9                	test   %ecx,%ecx
  800856:	74 12                	je     80086a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)
  800861:	8b 30                	mov    (%eax),%esi
  800863:	89 f7                	mov    %esi,%edi
  800865:	c1 ff 1f             	sar    $0x1f,%edi
  800868:	eb 10                	jmp    80087a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8d 50 04             	lea    0x4(%eax),%edx
  800870:	89 55 14             	mov    %edx,0x14(%ebp)
  800873:	8b 30                	mov    (%eax),%esi
  800875:	89 f7                	mov    %esi,%edi
  800877:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80087a:	85 ff                	test   %edi,%edi
  80087c:	78 0a                	js     800888 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80087e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800883:	e9 8c 00 00 00       	jmp    800914 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800893:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800896:	f7 de                	neg    %esi
  800898:	83 d7 00             	adc    $0x0,%edi
  80089b:	f7 df                	neg    %edi
			}
			base = 10;
  80089d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a2:	eb 70                	jmp    800914 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a4:	89 ca                	mov    %ecx,%edx
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a9:	e8 c0 fc ff ff       	call   80056e <getuint>
  8008ae:	89 c6                	mov    %eax,%esi
  8008b0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008b7:	eb 5b                	jmp    800914 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8008b9:	89 ca                	mov    %ecx,%edx
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	e8 ab fc ff ff       	call   80056e <getuint>
  8008c3:	89 c6                	mov    %eax,%esi
  8008c5:	89 d7                	mov    %edx,%edi
                        base = 8;
  8008c7:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8008cc:	eb 46                	jmp    800914 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8008ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8d 50 04             	lea    0x4(%eax),%edx
  8008f0:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008f3:	8b 30                	mov    (%eax),%esi
  8008f5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ff:	eb 13                	jmp    800914 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800901:	89 ca                	mov    %ecx,%edx
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
  800906:	e8 63 fc ff ff       	call   80056e <getuint>
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d7                	mov    %edx,%edi
			base = 16;
  80090f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800914:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800918:	89 54 24 10          	mov    %edx,0x10(%esp)
  80091c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80091f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800923:	89 44 24 08          	mov    %eax,0x8(%esp)
  800927:	89 34 24             	mov    %esi,(%esp)
  80092a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092e:	89 da                	mov    %ebx,%edx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	e8 6c fb ff ff       	call   8004a4 <printnum>
			break;
  800938:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80093b:	e9 cd fc ff ff       	jmp    80060d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800940:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80094d:	e9 bb fc ff ff       	jmp    80060d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800952:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800956:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80095d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800960:	eb 01                	jmp    800963 <vprintfmt+0x379>
  800962:	4e                   	dec    %esi
  800963:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800967:	75 f9                	jne    800962 <vprintfmt+0x378>
  800969:	e9 9f fc ff ff       	jmp    80060d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80096e:	83 c4 4c             	add    $0x4c,%esp
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 28             	sub    $0x28,%esp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800989:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 30                	je     8009c7 <vsnprintf+0x51>
  800997:	85 d2                	test   %edx,%edx
  800999:	7e 33                	jle    8009ce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099b:	8b 45 14             	mov    0x14(%ebp),%eax
  80099e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b0:	c7 04 24 a8 05 80 00 	movl   $0x8005a8,(%esp)
  8009b7:	e8 2e fc ff ff       	call   8005ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c5:	eb 0c                	jmp    8009d3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cc:	eb 05                	jmp    8009d3 <vsnprintf+0x5d>
  8009ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 7b ff ff ff       	call   800976 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    
  8009fd:	00 00                	add    %al,(%eax)
	...

00800a00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 01                	jmp    800a0e <strlen+0xe>
		n++;
  800a0d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a12:	75 f9                	jne    800a0d <strlen+0xd>
		n++;
	return n;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb 01                	jmp    800a27 <strnlen+0x11>
		n++;
  800a26:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	74 06                	je     800a31 <strnlen+0x1b>
  800a2b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2f:	75 f5                	jne    800a26 <strnlen+0x10>
		n++;
	return n;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a45:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a48:	42                   	inc    %edx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	75 f5                	jne    800a42 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5a:	89 1c 24             	mov    %ebx,(%esp)
  800a5d:	e8 9e ff ff ff       	call   800a00 <strlen>
	strcpy(dst + len, src);
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 c0 ff ff ff       	call   800a33 <strcpy>
	return dst;
}
  800a73:	89 d8                	mov    %ebx,%eax
  800a75:	83 c4 08             	add    $0x8,%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8e:	eb 0c                	jmp    800a9c <strncpy+0x21>
		*dst++ = *src;
  800a90:	8a 1a                	mov    (%edx),%bl
  800a92:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a95:	80 3a 01             	cmpb   $0x1,(%edx)
  800a98:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9b:	41                   	inc    %ecx
  800a9c:	39 f1                	cmp    %esi,%ecx
  800a9e:	75 f0                	jne    800a90 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab2:	85 d2                	test   %edx,%edx
  800ab4:	75 0a                	jne    800ac0 <strlcpy+0x1c>
  800ab6:	89 f0                	mov    %esi,%eax
  800ab8:	eb 1a                	jmp    800ad4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aba:	88 18                	mov    %bl,(%eax)
  800abc:	40                   	inc    %eax
  800abd:	41                   	inc    %ecx
  800abe:	eb 02                	jmp    800ac2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ac2:	4a                   	dec    %edx
  800ac3:	74 0a                	je     800acf <strlcpy+0x2b>
  800ac5:	8a 19                	mov    (%ecx),%bl
  800ac7:	84 db                	test   %bl,%bl
  800ac9:	75 ef                	jne    800aba <strlcpy+0x16>
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	eb 02                	jmp    800ad1 <strlcpy+0x2d>
  800acf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ad4:	29 f0                	sub    %esi,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae3:	eb 02                	jmp    800ae7 <strcmp+0xd>
		p++, q++;
  800ae5:	41                   	inc    %ecx
  800ae6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae7:	8a 01                	mov    (%ecx),%al
  800ae9:	84 c0                	test   %al,%al
  800aeb:	74 04                	je     800af1 <strcmp+0x17>
  800aed:	3a 02                	cmp    (%edx),%al
  800aef:	74 f4                	je     800ae5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 c0             	movzbl %al,%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b08:	eb 03                	jmp    800b0d <strncmp+0x12>
		n--, p++, q++;
  800b0a:	4a                   	dec    %edx
  800b0b:	40                   	inc    %eax
  800b0c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 14                	je     800b25 <strncmp+0x2a>
  800b11:	8a 18                	mov    (%eax),%bl
  800b13:	84 db                	test   %bl,%bl
  800b15:	74 04                	je     800b1b <strncmp+0x20>
  800b17:	3a 19                	cmp    (%ecx),%bl
  800b19:	74 ef                	je     800b0a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1b:	0f b6 00             	movzbl (%eax),%eax
  800b1e:	0f b6 11             	movzbl (%ecx),%edx
  800b21:	29 d0                	sub    %edx,%eax
  800b23:	eb 05                	jmp    800b2a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b36:	eb 05                	jmp    800b3d <strchr+0x10>
		if (*s == c)
  800b38:	38 ca                	cmp    %cl,%dl
  800b3a:	74 0c                	je     800b48 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3c:	40                   	inc    %eax
  800b3d:	8a 10                	mov    (%eax),%dl
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	75 f5                	jne    800b38 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b53:	eb 05                	jmp    800b5a <strfind+0x10>
		if (*s == c)
  800b55:	38 ca                	cmp    %cl,%dl
  800b57:	74 07                	je     800b60 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b59:	40                   	inc    %eax
  800b5a:	8a 10                	mov    (%eax),%dl
  800b5c:	84 d2                	test   %dl,%dl
  800b5e:	75 f5                	jne    800b55 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b71:	85 c9                	test   %ecx,%ecx
  800b73:	74 30                	je     800ba5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7b:	75 25                	jne    800ba2 <memset+0x40>
  800b7d:	f6 c1 03             	test   $0x3,%cl
  800b80:	75 20                	jne    800ba2 <memset+0x40>
		c &= 0xFF;
  800b82:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	c1 e3 08             	shl    $0x8,%ebx
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	c1 e6 18             	shl    $0x18,%esi
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	c1 e0 10             	shl    $0x10,%eax
  800b94:	09 f0                	or     %esi,%eax
  800b96:	09 d0                	or     %edx,%eax
  800b98:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b9d:	fc                   	cld    
  800b9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba0:	eb 03                	jmp    800ba5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba2:	fc                   	cld    
  800ba3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba5:	89 f8                	mov    %edi,%eax
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bba:	39 c6                	cmp    %eax,%esi
  800bbc:	73 34                	jae    800bf2 <memmove+0x46>
  800bbe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc1:	39 d0                	cmp    %edx,%eax
  800bc3:	73 2d                	jae    800bf2 <memmove+0x46>
		s += n;
		d += n;
  800bc5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	f6 c2 03             	test   $0x3,%dl
  800bcb:	75 1b                	jne    800be8 <memmove+0x3c>
  800bcd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd3:	75 13                	jne    800be8 <memmove+0x3c>
  800bd5:	f6 c1 03             	test   $0x3,%cl
  800bd8:	75 0e                	jne    800be8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bda:	83 ef 04             	sub    $0x4,%edi
  800bdd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800be3:	fd                   	std    
  800be4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be6:	eb 07                	jmp    800bef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be8:	4f                   	dec    %edi
  800be9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bec:	fd                   	std    
  800bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bef:	fc                   	cld    
  800bf0:	eb 20                	jmp    800c12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf8:	75 13                	jne    800c0d <memmove+0x61>
  800bfa:	a8 03                	test   $0x3,%al
  800bfc:	75 0f                	jne    800c0d <memmove+0x61>
  800bfe:	f6 c1 03             	test   $0x3,%cl
  800c01:	75 0a                	jne    800c0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c06:	89 c7                	mov    %eax,%edi
  800c08:	fc                   	cld    
  800c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0b:	eb 05                	jmp    800c12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0d:	89 c7                	mov    %eax,%edi
  800c0f:	fc                   	cld    
  800c10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 77 ff ff ff       	call   800bac <memmove>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4b:	eb 16                	jmp    800c63 <memcmp+0x2c>
		if (*s1 != *s2)
  800c4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c50:	42                   	inc    %edx
  800c51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c55:	38 c8                	cmp    %cl,%al
  800c57:	74 0a                	je     800c63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c59:	0f b6 c0             	movzbl %al,%eax
  800c5c:	0f b6 c9             	movzbl %cl,%ecx
  800c5f:	29 c8                	sub    %ecx,%eax
  800c61:	eb 09                	jmp    800c6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c63:	39 da                	cmp    %ebx,%edx
  800c65:	75 e6                	jne    800c4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7a:	89 c2                	mov    %eax,%edx
  800c7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c7f:	eb 05                	jmp    800c86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c81:	38 08                	cmp    %cl,(%eax)
  800c83:	74 05                	je     800c8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c85:	40                   	inc    %eax
  800c86:	39 d0                	cmp    %edx,%eax
  800c88:	72 f7                	jb     800c81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c98:	eb 01                	jmp    800c9b <strtol+0xf>
		s++;
  800c9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	8a 02                	mov    (%edx),%al
  800c9d:	3c 20                	cmp    $0x20,%al
  800c9f:	74 f9                	je     800c9a <strtol+0xe>
  800ca1:	3c 09                	cmp    $0x9,%al
  800ca3:	74 f5                	je     800c9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca5:	3c 2b                	cmp    $0x2b,%al
  800ca7:	75 08                	jne    800cb1 <strtol+0x25>
		s++;
  800ca9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800caa:	bf 00 00 00 00       	mov    $0x0,%edi
  800caf:	eb 13                	jmp    800cc4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb1:	3c 2d                	cmp    $0x2d,%al
  800cb3:	75 0a                	jne    800cbf <strtol+0x33>
		s++, neg = 1;
  800cb5:	8d 52 01             	lea    0x1(%edx),%edx
  800cb8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cbd:	eb 05                	jmp    800cc4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc4:	85 db                	test   %ebx,%ebx
  800cc6:	74 05                	je     800ccd <strtol+0x41>
  800cc8:	83 fb 10             	cmp    $0x10,%ebx
  800ccb:	75 28                	jne    800cf5 <strtol+0x69>
  800ccd:	8a 02                	mov    (%edx),%al
  800ccf:	3c 30                	cmp    $0x30,%al
  800cd1:	75 10                	jne    800ce3 <strtol+0x57>
  800cd3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cd7:	75 0a                	jne    800ce3 <strtol+0x57>
		s += 2, base = 16;
  800cd9:	83 c2 02             	add    $0x2,%edx
  800cdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce1:	eb 12                	jmp    800cf5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	75 0e                	jne    800cf5 <strtol+0x69>
  800ce7:	3c 30                	cmp    $0x30,%al
  800ce9:	75 05                	jne    800cf0 <strtol+0x64>
		s++, base = 8;
  800ceb:	42                   	inc    %edx
  800cec:	b3 08                	mov    $0x8,%bl
  800cee:	eb 05                	jmp    800cf5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cfc:	8a 0a                	mov    (%edx),%cl
  800cfe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d01:	80 fb 09             	cmp    $0x9,%bl
  800d04:	77 08                	ja     800d0e <strtol+0x82>
			dig = *s - '0';
  800d06:	0f be c9             	movsbl %cl,%ecx
  800d09:	83 e9 30             	sub    $0x30,%ecx
  800d0c:	eb 1e                	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d11:	80 fb 19             	cmp    $0x19,%bl
  800d14:	77 08                	ja     800d1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d16:	0f be c9             	movsbl %cl,%ecx
  800d19:	83 e9 57             	sub    $0x57,%ecx
  800d1c:	eb 0e                	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d21:	80 fb 19             	cmp    $0x19,%bl
  800d24:	77 12                	ja     800d38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d26:	0f be c9             	movsbl %cl,%ecx
  800d29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d2c:	39 f1                	cmp    %esi,%ecx
  800d2e:	7d 0c                	jge    800d3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d30:	42                   	inc    %edx
  800d31:	0f af c6             	imul   %esi,%eax
  800d34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d36:	eb c4                	jmp    800cfc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d38:	89 c1                	mov    %eax,%ecx
  800d3a:	eb 02                	jmp    800d3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d42:	74 05                	je     800d49 <strtol+0xbd>
		*endptr = (char *) s;
  800d44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d49:	85 ff                	test   %edi,%edi
  800d4b:	74 04                	je     800d51 <strtol+0xc5>
  800d4d:	89 c8                	mov    %ecx,%eax
  800d4f:	f7 d8                	neg    %eax
}
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
	...

00800d58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d58:	55                   	push   %ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	83 ec 10             	sub    $0x10,%esp
  800d5e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d6e:	89 cd                	mov    %ecx,%ebp
  800d70:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	75 2c                	jne    800da4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d78:	39 f9                	cmp    %edi,%ecx
  800d7a:	77 68                	ja     800de4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d7c:	85 c9                	test   %ecx,%ecx
  800d7e:	75 0b                	jne    800d8b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	31 d2                	xor    %edx,%edx
  800d87:	f7 f1                	div    %ecx
  800d89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	89 f8                	mov    %edi,%eax
  800d8f:	f7 f1                	div    %ecx
  800d91:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d93:	89 f0                	mov    %esi,%eax
  800d95:	f7 f1                	div    %ecx
  800d97:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800da4:	39 f8                	cmp    %edi,%eax
  800da6:	77 2c                	ja     800dd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800da8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dab:	83 f6 1f             	xor    $0x1f,%esi
  800dae:	75 4c                	jne    800dfc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800db2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db7:	72 0a                	jb     800dc3 <__udivdi3+0x6b>
  800db9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dbd:	0f 87 ad 00 00 00    	ja     800e70 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc8:	89 f0                	mov    %esi,%eax
  800dca:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    
  800dd3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800de4:	89 fa                	mov    %edi,%edx
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	f7 f1                	div    %ecx
  800dea:	89 c6                	mov    %eax,%esi
  800dec:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dee:	89 f0                	mov    %esi,%eax
  800df0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dfc:	89 f1                	mov    %esi,%ecx
  800dfe:	d3 e0                	shl    %cl,%eax
  800e00:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e04:	b8 20 00 00 00       	mov    $0x20,%eax
  800e09:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e0b:	89 ea                	mov    %ebp,%edx
  800e0d:	88 c1                	mov    %al,%cl
  800e0f:	d3 ea                	shr    %cl,%edx
  800e11:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e15:	09 ca                	or     %ecx,%edx
  800e17:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e1b:	89 f1                	mov    %esi,%ecx
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e23:	89 fd                	mov    %edi,%ebp
  800e25:	88 c1                	mov    %al,%cl
  800e27:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e29:	89 fa                	mov    %edi,%edx
  800e2b:	89 f1                	mov    %esi,%ecx
  800e2d:	d3 e2                	shl    %cl,%edx
  800e2f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e33:	88 c1                	mov    %al,%cl
  800e35:	d3 ef                	shr    %cl,%edi
  800e37:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e39:	89 f8                	mov    %edi,%eax
  800e3b:	89 ea                	mov    %ebp,%edx
  800e3d:	f7 74 24 08          	divl   0x8(%esp)
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e45:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e49:	39 d1                	cmp    %edx,%ecx
  800e4b:	72 17                	jb     800e64 <__udivdi3+0x10c>
  800e4d:	74 09                	je     800e58 <__udivdi3+0x100>
  800e4f:	89 fe                	mov    %edi,%esi
  800e51:	31 ff                	xor    %edi,%edi
  800e53:	e9 41 ff ff ff       	jmp    800d99 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e58:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e5c:	89 f1                	mov    %esi,%ecx
  800e5e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e60:	39 c2                	cmp    %eax,%edx
  800e62:	73 eb                	jae    800e4f <__udivdi3+0xf7>
		{
		  q0--;
  800e64:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e67:	31 ff                	xor    %edi,%edi
  800e69:	e9 2b ff ff ff       	jmp    800d99 <__udivdi3+0x41>
  800e6e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e70:	31 f6                	xor    %esi,%esi
  800e72:	e9 22 ff ff ff       	jmp    800d99 <__udivdi3+0x41>
	...

00800e78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e78:	55                   	push   %ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	83 ec 20             	sub    $0x20,%esp
  800e7e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e82:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e86:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e8a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e92:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e96:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800e98:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e9a:	85 ed                	test   %ebp,%ebp
  800e9c:	75 16                	jne    800eb4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800e9e:	39 f1                	cmp    %esi,%ecx
  800ea0:	0f 86 a6 00 00 00    	jbe    800f4c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ea8:	89 d0                	mov    %edx,%eax
  800eaa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eac:	83 c4 20             	add    $0x20,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eb4:	39 f5                	cmp    %esi,%ebp
  800eb6:	0f 87 ac 00 00 00    	ja     800f68 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ebc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ebf:	83 f0 1f             	xor    $0x1f,%eax
  800ec2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec6:	0f 84 a8 00 00 00    	je     800f74 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ecc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ed0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ed2:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800edb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800edf:	89 f9                	mov    %edi,%ecx
  800ee1:	d3 e8                	shr    %cl,%eax
  800ee3:	09 e8                	or     %ebp,%eax
  800ee5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800ee9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef1:	d3 e0                	shl    %cl,%eax
  800ef3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ef7:	89 f2                	mov    %esi,%edx
  800ef9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800efb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800eff:	d3 e0                	shl    %cl,%eax
  800f01:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f05:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f09:	89 f9                	mov    %edi,%ecx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f0f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f11:	89 f2                	mov    %esi,%edx
  800f13:	f7 74 24 18          	divl   0x18(%esp)
  800f17:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f19:	f7 64 24 0c          	mull   0xc(%esp)
  800f1d:	89 c5                	mov    %eax,%ebp
  800f1f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f21:	39 d6                	cmp    %edx,%esi
  800f23:	72 67                	jb     800f8c <__umoddi3+0x114>
  800f25:	74 75                	je     800f9c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f27:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f2b:	29 e8                	sub    %ebp,%eax
  800f2d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f2f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f33:	d3 e8                	shr    %cl,%eax
  800f35:	89 f2                	mov    %esi,%edx
  800f37:	89 f9                	mov    %edi,%ecx
  800f39:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f3b:	09 d0                	or     %edx,%eax
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f43:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f45:	83 c4 20             	add    $0x20,%esp
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f4c:	85 c9                	test   %ecx,%ecx
  800f4e:	75 0b                	jne    800f5b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f50:	b8 01 00 00 00       	mov    $0x1,%eax
  800f55:	31 d2                	xor    %edx,%edx
  800f57:	f7 f1                	div    %ecx
  800f59:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f5b:	89 f0                	mov    %esi,%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f61:	89 f8                	mov    %edi,%eax
  800f63:	e9 3e ff ff ff       	jmp    800ea6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f68:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f6a:	83 c4 20             	add    $0x20,%esp
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    
  800f71:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f74:	39 f5                	cmp    %esi,%ebp
  800f76:	72 04                	jb     800f7c <__umoddi3+0x104>
  800f78:	39 f9                	cmp    %edi,%ecx
  800f7a:	77 06                	ja     800f82 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f7c:	89 f2                	mov    %esi,%edx
  800f7e:	29 cf                	sub    %ecx,%edi
  800f80:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f82:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    
  800f8b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f8c:	89 d1                	mov    %edx,%ecx
  800f8e:	89 c5                	mov    %eax,%ebp
  800f90:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800f94:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800f98:	eb 8d                	jmp    800f27 <__umoddi3+0xaf>
  800f9a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f9c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fa0:	72 ea                	jb     800f8c <__umoddi3+0x114>
  800fa2:	89 f1                	mov    %esi,%ecx
  800fa4:	eb 81                	jmp    800f27 <__umoddi3+0xaf>
