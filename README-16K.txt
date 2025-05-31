Package contents:

- ROMs:
16k-hdbdw3arduino.rom     Arduino
16k-hdbdw3bck.rom         Becker
16k-hdbdw3bckt.rom        Becker (with timeout)
16k-hdbdw3bckwifi.rom     Becker (different address for WiFi)
16k-hdbtc3.rom            Cloud-9 TC^3 SCSI Interface
16k-hdbsdc.rom            CoCoSDC
16k-hdbd4n1.rom           Disto 4-N-1 SCSI
16k-hdbdhdii.rom          Disto HD-II
16k-hdbdw3cc1.rom         DriveWire 3 (CoCo 1)
16k-hdbdw3cc2.rom         DriveWire 3 (CoCo 2)
16k-hdbdw3ln.rom          DriveWire 3 (CoCoLINK RS232 Pak)
16k-hdbdw3sy.rom          DriveWire 3 (Deluxe RS232 Pak)
16k-hdbdw3dm.rom          DriveWire 3 (Direct Modem RS232 Pak)
16k-hdbdw3dg.rom          DriveWire 3 (Dragon in CoCo mode)
16k-hdbchs.rom            IDE CHS
16k-hdblba.rom            IDE LBA
16k-hdbdw3jc2.rom         J&M Disk Controller
16k-hdbkenton.rom         Kenton SCSI Interface
16k-hdblrtech.rom         LRTech Controller

- Listing files
*.rom.lst                 Source with generated machine code, one for each of
                          the above ROMs

- Patch:
hdbdos-16k.patch          Changes to generate HDB-DOS/16K, applies cleanly to
                          ToolShed GitHub repository as of May 31, 2025
                          (https://github.com/nitros9project/toolshed)

README.txt                This file


TO DO:

- ON BRK
- Option to boot in text mode:
  - Different ROM for default in text mode
  - One hot key to swap the text mode at boot
- Make some use of a 6309
- Make the AND and OR operators accept values from -2^31 to 2^31-1
  - Create a XOR operator
- Support for text-mode inverse video and (in the 6847T1) lowercase
- Create a BIN$ function (nobody cares about OCT$)


WIP:

- ON ERR
  - Error trapping works, now to implement the ONERR statement and save
    the BASIC line in which ONERR was executed


SUMMARY OF CHANGES:

- All CoCo 3 tokens are recognized, so a CoCo 3 BASIC program will not be
  garbled upon loading
- 51x24 and 64x24 text modes in PMODE 4, switchable with WIDTH command
- LOCATE works as expected - works in the 32x16 screen too, unlike the CoCo3
- Support for BUTTON function including 2nd joystick button (requires internal
  wiring; testers welcome)
- DIR output uses available screen width
- TIMERL function similar to TIMER but wraps at 2^32 (2 years, 98.5 days)
- HSET MEM COPY moves BASIC to RAM in 64KB machines; HSET MEM and HRESET MEM
  switch to RAM and ROM respectively
- HSET COLOR 1 sets text screen to orange; HSET COLOR 0 sets it back to green.
- HPOINT gives you some system information:
  - HPOINT(0) returns the CPU model (6809 or 6309)
  - HPOINT(1) is planned to return whether the 6309 is running in Native Mode.
    (Currently, always returns zero.)
  - HPOINT(2) returns whether BASIC is running from RAM (see HSET MEM)
  - HPOINT(3) returns the address of a useful data area for manipulating the
    new graphics-text mode (cursor blink, shape etc); see new file
    cocoroms/rom16kvars.asm
  - HPOINT(4) returns the frequency of timer interrupts - 50 for PAL, 60 for
    NTSC - this is the value you need to divide TIMER/TIMERL by to get seconds
- BASIC printer output redirected to DriveWire virtual printer (experimental),
  now with a flag in the aforementioned data area to disable redirection,
  still with no BASIC interface to control it
- Accepts binary constants with &B, just like &H and &O
  - Also, these notations can yield values up to 2^32-1
  - Ancient bug in &O (accepted 8 as a digit) fixed
- Conversely, HEX$ now accepts values up to 2^32-1
- ERNO and ERLIN - not much use until ONERR works
  - Differently from the CoCo 3, they can be examined in direct mode after
    the BASIC program ends.


ADDED FILES:

cocoroms/rom16kvars.asm
hdbdos/README-16K.txt
hdbdos/el.asm
hdbdos/font51.asm
hdbdos/font64.asm
hdbdos/mk16kpackage.sh
hdbdos/mkslacklist.sh
hdbdos/build-hdbdos-16k.sh
hdbdos/buildmsg.asm
