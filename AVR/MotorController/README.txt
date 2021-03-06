SMG notes:
  This code uses SMG (http://smg.sourceforge.net/) to generate the state machine
  at the core of the program. The firmware makefile passes some options that are
  only supported by a customized version of SMG, which can be found here:
  https://github.com/jlefley/SMG

  The repository contains the files generated by SMG (StateMachine.cpp and
  StateMachine_smdefs.h) so SMG is only required if you change StateMachine.sm.

  In the event that you require SMG, follow this procedure to install it:

    In a shell enter these commands:

      git clone https://github.com/jlefley/SMG.git
      cd SMG
      sudo python setup.py install
      cd
      python

    At the python prompt enter these commands:

      import smg
      smg.__path__

    The Python interpreter will print out the path to the SMG installation. Press
    Ctrl+D to exit the Python prompt. Enter these commands into a shell,
    substituting the path to SMG printed by Python (['<smg-path>']) for
    <smg-path> below.
      
      sudo ln -s <smg-path>/smg.py /usr/local/bin/smg
      sudo chmod +x /usr/local/bin/smg

  For more information, see INSTALL in the SMG directory created after cloning the
  git repository. 

Other notes:
  The default make target generates a hex file but it does not insert the
  program length required by the bootloader scheme. This is so make can
  still build the firmware if srec_cat is not present. To generate a hex file
  for use with the bootloader, run "make release". Use the resulting
  MotorController.hex and MotorController.crc16 in conjunction with the
  bootloader scheme.

  You can enable a debug build by setting DEBUG to 1 in the makefile.  A debug
  build will print out state transitions and other useful information over the
  AVR's UART hardware interface.
 
  Note that as of 06/2015, the production Ember hardware does not have the
  hardware UART I/O pins connected to an easily accessible header so the debug
  output is really only accessible with a "breadboard" setup. The 6 pin headers
  near the AVRs on the production hardware is connected to I/O pins other than the
  those connected to the UART hardware within the AVR.  This requires a software
  approach to driving the UART connection, which is not straightforward to
  implement given the possibility of timing issues due to the interrupts in the
  code.

  Writing out the debug logging via the UART interface takes considerable time
  and will cause the main firmware to get out of sync with the interrupts coming
  from the motor controller firmware if a debug build is used during actual
  printing.

