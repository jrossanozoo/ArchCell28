This is a timer fll program for VFP 5 and 6. The purpose of this fll, to make a better timer, than
VFP native timer. The native timer isnot fired, when a modal form is on the screen, and the timer 
is on an other form. But this cpptimer will fired even at this cases! And, these cpptimers donnot 
require form to use them. The usage of them is very easy:

 The available functions:

InitTimers( iMaxNumberOfTimers, iTimerResolution)
  iMaxNumberOfTimers: The number of timers, that you want to handle in your program with this fll
                      It supports up to 50 timers. 
  iTimerResolution:  The timer resolution in milliseconds. The less resolution value means, more 
                     overhead for system. (Suggested value is half of the minimal timer interval) 
                     The minimal value is 1. It is not guaranted, that your system can fired events
                     as often as you want. To test the available shortest resolution, run TimerRes.prg
                     (The values may vary system to system and depends on CPU loading, also. Typically,
                      on Pentium233, NT4, VFP5: 10-20 ms )
  Remarks:  Before executing any SetupTimer() function you have to call this function. At calling 
            this function, all active timers will disabled, so you have to setup them again with 
            SetupTimer function. In a program you can call it as many times as you wish. At every 
            iTimerResolution milisecond the fll examines if any timer should fired or not. 
            You can re-create timers.
  Example:  InitTimers(3,120)          
  
  
SetupTimer (iTimerIndex, iTimerInterval, cCommandToExecute)  
  Return:  index of timer was setup on succes, -1 on error
   
  iTimerNo: The index of timer, that this funtion will setup. If you want to setup the next available
            timer, use zero. (Value must be between 0 and iMaxNumberOfTimers of InitTimers function)
  iTimerInterval: The time interval of timer in miliseconds. At the end of every iTimerInterval 
                  miliseconds, a timer event occurs.(Value must be more or equal than 
                  iTimerResolution of InitTimers function)
  cCommandToExecute: The command line that fll will execute at timer events of this timer.
  
  Remarks: Each timer has its own interval and command. If an execution time of a command is long, 
          a new timer event can occur only after it ends. But the priority among timers is equal. 
          So all timers are fired after each other, if their time interval is elapsed during 
          the prevoius command execution.
          You can redefine ("re-setup") any timer at any time. It means that you can change the
          cCommandToExecute or timerinterval any time, even in the function or procedure 
          that is executed at timer events.
          There are cases, when timer events are generated but VFP cannot execute the specified
          commands, but number of these cases are less, than at VFP timer object. At these cases 
          the timer event will be cashed but only one event for each timer. 
          (E.g. during SQL selecting events are fired and executed!)
                   
  Example:  SetupTimer(2,5000,"myfunc(34)")   
            The 2nd timer will fired at every 5 seconds. At these events myfunc function will 
            executed with the parameter 34.       
            SetupTimer(3,5000,"_vfp.activeform.myfunc(34)")   
            The 3rd timer will fired at every 5 seconds. At these events myfunc function of 
            active form will executed with the parameter 34.       

StopTimer (iTimerIndex)           
   iTimerNo: The index of timer, that this funtion will stop. (Value must be between 1 and 
             iMaxNumberOfTimers of InitTimers function)                          
   Remarks: This function will stop the specified timer. You have to setup it if you want 
            to use again.
                         
KillTimers()
   Remarks:  This function will stop all timers installed by SetupTimer function.
             If you want to use any timer again, you have to issue InitTimers and SetupTimer
             functions again.                         
             Although at unloading of the fll this function is automatically called, it is 
             recommended to issue this function explicitly, because at cashed events, a 
             Invalid Memory Write system error could occur!

GetFreeTimerIndex()
   Remarks: This function returns the index of first (i.e. lowest) not running timer. 
            (Not running timer: Stopped or still not started) If no timer is available returns zero.

The sample files:
Timer.prg and timerprc.prg
Copy all files into any directory. And start timer.prg  The program starts 5 timer with different
intervals. At every timer events the TimerFunc function of timerprog.prg will called. This function 
displays the the ID of fired timer and the real interval since last event of this timer.
You can change the interval of any timer or stop with issuing the previous functions in command window
E.G.:
If you want to stop the 2nd timer issue in the command window: StopTimer(2)            
If you want to the 4th timer fired in every second and display "HELLO": 
           SetupTimer(4,1000,"? 'Hello' ")
To remove the fll from memory, don't forget issue: Set Library To  

If you have any comment or question to this fll, please let me know. 
You can register yourself, to get the enhancements:

You can e-mail me:
      bodecsb@mail.matav.hu  or
      officeline@mail.matav.hu

Or phone: + 36 30 9 443 113 (Central European TimeZone)
          + 36 30 9 912 050
          
If you enjoy this software and want to register yourself to get the latest updated versions continously,
send a 10 USD AMERICAN EXPRESS GIFT or TRAVELLERS CHECK to the author:
Bela Bodecs
   Hungary
   1464
   Budapest
   pf 1550

P.S.: I enclose the source code, which is good for VC4.2++ and is not necessary that 
      this is same as  this final version. Sorry, but some comments are in Hungarian.
P.S.2: To run this fll you need to have MSVCRT.DLL on your machine. It is shipped with 
       NT4 and WIN95 OSR2, but not with older WIN95. (So I include it into this zip)
       If you get an "Invalid or corrupted Libary" error message on loading fll, it means 
       you miss this file. Copy it to the same directory where fll is, or into the system directory. 
       (You can read about it in MS KB: Q157317)

All program and source code is freeware and As Is. Any warranty or damage caused by this program ...
You can modify it as you want. 

Good luck!!

Revision history:
1998. jun 18.  Creating x timer only x-1 were available. Now It is corrected
1998. nov 20.  Error messages were added
1998. dec 8.   GetFreeTimerIndex function was added and 0 timer index in SetupTimer is applicable
1998. dec 27. Minor internal bug was repaired