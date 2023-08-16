# Multy-Cycle-CPU

The Top entity in this design is a module that combines a datapath and a control unit to create a fully functioning CPU-based controller.
The input signals of the top entity include the clock , reset and enable signals, as well as a test bench input vector , which is used for initializing the memory before running a program. 
The output signals of the top module are only for test bench. The first output is a vector which used for reading the data memory after the program is ending.  
The other is a signal which indicates when the CPU has completed executing program.

Datapath:
The datapath consists of a collection of functional units such as registers, arithmetic logic unit (ALU),  Registers file , data memory, program memory ext..
The datapath gets the current control signals as an input vector. The control signals define which data transitions and calculations should be done in the datapath’s components.
 The output of the datapath is a decoded instruction (status) vector, which goes to the control unit. 


Control Unit:
The control unit is responsible for coordinating the activities of the datapath and memory units to carry out the instructions of a program.
 It is typically implemented as a simple finite-state machine (FSM) that generates the appropriate control signals to configure the datapath for each instruction of the program. 
A description of the simple FSM is in designGrapg.pdf file.
The control unit reads the decoded instruction ( plus current flags) from a status vector. It generates the appropriate control signals that instruct the datapath on what operations to perform.
 The current state of the FSM can be changed only when ena signal is on. 
