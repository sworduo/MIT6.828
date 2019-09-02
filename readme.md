#	MIT6.828——操作系统
&emsp;&emsp;MIT6.828是在江湖上流传已久的神级课程之一，主要讲述操作系统，从宏观层面剖析操作系统的核心设计理念，通过教学与实践合一的方式，让萌新快速构建对操作系统的基本认识。操作系统的设计目的之一是为了更好的管理和分配计算机资源，这种资源包括计算资源——cpu，中间资源——内存，存储资源——硬件，为了各个部分各司其职，互不干扰，操作系统提出了抽象的概念，将提供给用户的各种资源以不同的形式分割，并规定了跨资源之间的沟通方式。如此一来，所有数据传输、命令传递、数据交换、资源共享等都有了一种约束与制度。除此之外，操作系统保留了资源分配的核心实现，只暴露了可供用户操作的API，实现与接口的分离，使得用户无需操心底层交互的实现，而仅仅关注需要获取资源的任务即可。

#	相关资源
课程主页：[6.828:Operating System Engineering](https://pdos.csail.mit.edu/6.828/2018/schedule.html)  
xv6讲义：[a simple, Unix-like teaching operating system](https://pdos.csail.mit.edu/6.828/2018/xv6/book-rev11.pdf)  
环境搭建：[MIT-6.828-JOS-环境搭建](https://www.cnblogs.com/gatsby123/p/9746193.html)  
>环境搭建，在qemu make的时候如果出现没有权限在某某文件夹下创建文件的错误，那么就修改这个文件夹的权限或者所有者就可以了。

#	课程作业
&emsp;&emsp;课程作业是帮助我们快速适应类unix系统特性的捷径。让我们熟悉将要实现的操作系统的一些操作，对以后要实现的功能心里有数。在学习时，可能会因为xv6和JOS交替出现而感到困惑，事实上，xv6是一个类Unix的教学操作系统，经过多年的教学验证和学生反馈修改，已经较为完善，而JOS是在xv6的基础上改写的，让我们能够在上面实验OS。所以两者在很大程度上是重叠的，可以通过阅读xv6的代码来增加对JOS的理解。  
- [ ] [Homework1: boot xv6](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-boot.html)  
- [ ] [Homework2: shell](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-shell.html)  
- [ ] [Homework3: xv6 system calls](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-syscall.html)  
- [ ] [Homework4: xv6 lazy page allocation](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-zero-fill.html)  
- [ ] [Homework5: xv6 CPU alarm](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-alarm.html)  
- [ ] [Homework6: Threads and Locking](https://pdos.csail.mit.edu/6.828/2018/homework/lock.html)  
- [ ] [Homework7: xv6 locking](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-lock.html)  
- [ ] [Homework8: User-level threads](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-uthread.html)  
- [ ] [Homework9: Barriers](https://pdos.csail.mit.edu/6.828/2018/homework/barrier.html)  
- [ ] [Homework10: bigger files for xv6](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-big-files.html)  
- [ ] [Homework11: xv6 log](https://pdos.csail.mit.edu/6.828/2018/homework/xv6-new-log.html)  
- [ ] [Homework12: mmap()](https://pdos.csail.mit.edu/6.828/2018/homework/mmap.html)  

#	课程实验
&emsp;&emsp;实践是验证知识，查缺补漏最好的方式。只有真正将理论付诸于现实时，才会察觉到许许多多不曾被重视却又至关重要的细节。  
- [ ] [Lab1:Booting a PC](https://pdos.csail.mit.edu/6.828/2018/labs/lab1/)  
	- [ ] Part1:PC Bootstrap  
	- [ ] Part2:The Boot Loader  
	- [ ] Part3:The Kernel  
- [ ] [Lab2:Memory Management](https://pdos.csail.mit.edu/6.828/2018/labs/lab3/)  
	- [ ] Part1:Physical Page Management  
	- [ ] Part2:Virtual Memory  
	- [ ] Part3:Kernel Address Space  
- [ ] [Lab3:User Environments](https://pdos.csail.mit.edu/6.828/2018/labs/lab3/)  
	- [ ] Part1:User Environments and Exception Handing  
	- [ ] Part2:Page Faults, Breakpoints Exceptions, and System Calls  
- [ ] [Lab4:Preemptive Multitasking](https://pdos.csail.mit.edu/6.828/2018/labs/lab4/)  
	- [ ] Part1:Multiprocessor Support and Cooperative Multitasking  
	- [ ] Part2:Copy-on-Write Fork  
	- [ ] Part3:Preemptive Multitasking and Inter-Process communication(IPC)  
- [ ] [Lab5:File system, Spawn and Shell](https://pdos.csail.mit.edu/6.828/2018/labs/lab5/)  
- [ ] [Lab6:Network Driver](https://pdos.csail.mit.edu/6.828/2018/labs/lab6/)  
	- [ ] Part1:Initialization and transmitting packets  
	- [ ] Part2:Receiving packets and the web server   
	
#	参考
&emsp;&emsp;以下是我在实现过程中给予我帮助或者指引我思考方向的参考。参考文献应该是自己实现后的对比验证，而不应该是无脑抄袭，应该先想后做再验证，而不要一上来就看各种大佬是怎么写的。当然，如果苦思冥想了很久还是没有思路，那还是老老实实看看大佬的想法吧。有些东西，没有积累，凭空想是很难想出来的。当然，这时候看的应该是大佬的思路，然后思索这么实现的优劣，融会贯通后自己写一遍，而不是真的抄一遍代码。   
 
[MIT6.828-神级OS课程-要是早遇到，我还会是这种 five 系列](https://zhuanlan.zhihu.com/p/74028717)  
[某大神博客](https://blog.csdn.net/bysui/article/category/6232831)  