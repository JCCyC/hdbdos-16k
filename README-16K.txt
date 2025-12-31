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
hdbdos-16k.patch          Changes to generate HDB-DOS/16, applies cleanly to
                          ToolShed GitHub repository as of Dec 31, 2025
                          (https://github.com/nitros9project/toolshed)

README.txt                This file


ISSUES:

- Errors in disk functions are sometimes not correctly intercepted - program
  silently ends instead.
- LINE INPUT #file,var$ clobbers bit 7 of text data, whereas
  INPUT #file,var$ doesn't.
- Sometimes RENUM gives an error. Hard to reproduce for now.


TO DO:

- ON BRK
- Option to boot in text mode:
  - Different ROM for default in text mode?
  - One hot key to swap the text mode at boot?
- Make the AND and OR operators accept values from -2^31 to 2^31-1.
  - Create a XOR operator
- Manipulate the sector offset (HDBHI/HDBLO).
- Enhance RENUM so it can renumber the first portion of a program, as opposed
  to only the second portion like it is currently in ECB.
- Allow GET #file,record# to obtain partial strings at EOF.
- Utility to show memory layout.
- LOAD CHR$ to load an alternate text font for different code pages, either in
  its standard location when in RAM mode, or in user memory when in ROM mode.
- A subset of ANSI control codes for use as a terminal.
- RESTORE <line> like in other BASIC's. But the syntax will have to be
  something like RESTORE GOTO <line> in order to RENUM to be able to deal
  with it.
- Make handling of string constants in BASIC code a bit less US-centric:
  - Characters > $7F between double quotes shouldn't be detokenized at LIST.
  - If the program was saved in ASCII, even if you edit characters > $7F into
    string constants, their bit 7 gets zeroed out upon LOAD. This needs to be
    changed.
  - Cook up a way to edit programs within BASIC in a way that (a) preserves
    string constants, and (b) lets you type > $7F characters.


WIP:

- Allow putting BASIC in 6309 Native Mode, i.e., change interrupt handling
  for different stack layout in NMI (simple) and IRQ (complicated) handlers.


SUMMARY OF CHANGES:

- All CoCo 3 tokens are recognized, so a CoCo 3 BASIC program will not be
  garbled upon loading -- this required reproducing an off-by-one bug in
  CoCo 3's tokenizing code.
- 51x24 and 64x24 text modes in PMODE 4, switchable with WIDTH command.
  - Requires at least 4 graphics pages (6K) PCLEARed; forces PMODE 4.
  - PRINT@ works as expected, with the maximum position being 1223 in 51x24
    mode and 1535 in 64x24 mode.
  - The charset defined in ROM is ISO-8859-15, although it's possible to
    redefine it with HSET MEM COPY and HPOINT(5). (See below)
  - If an AUTOEXEC.BAS program is auto-executed at boot or by the DOS command,
    the screen is put in text mode, for compatibility with programs that don't
    expect to find themselves in a PMODE 4 that character output doesn't get
    you out of. (e.g. Sidekick)
- LOCATE works as expected.
  - Works in the 32x16 screen too, unlike the CoCo 3.
- Support for BUTTON function including 2nd joystick button. (Requires internal
  wiring; testers welcome.)
- DIR output uses available screen width.
- TIMERL function similar to TIMER but wraps at 2^32. (2 years, 98.5 days)
- TIMER FOR N waits N seconds. (N may be a fraction: TIMER FOR 1.5 waits 1.5s)
- HSET MEM COPY moves BASIC to RAM in 64KB machines; HSET MEM and HRESET MEM
  switch to RAM and ROM respectively.
- HSET COLOR n sets text color:
  - 0: dark border, black-on-green characters (default)
  - 1: dark border, black-on-orange characters
  - 2: dark border, green-on-black characters
  - 3: dark border, orange-on-black characters
  - 4: light border, black-on-green characters
  - 5: light border, black-on-orange characters
  - 6: light border, green-on-black characters
  - 7: light border, orange-on-black characters
  - In graphics mode, only the green-on-black/black-on-green setting works.
  - Border color setting only works in CoCos with a 6847T1 video controller.
- HSET LSET 1 activates lowercase characters, HSET LSET 0 gets back to
  inverse-as-lowercase default mode. (Only works in CoCos with a 6847T1; resets
  inverse mode if active)
- HSET INPUT <character> sets the cursor character. For example:
  - HSET INPUT CHR$(95) sets the cursor to a thin underline instead of the
    default thick underline.
  - HSET INPUT CHR$(124) sets the cursor to a vertical bar like in GUI OSs.
- HSET F puts the CPU in fast mode (1.78 MHz) when accessing the ROM. This is
  the "conservative" fast mode, which will work even with older CoCos. HSET S
  gets back to slow mode.
- HPOINT gives you some system information:
  - HPOINT(0) returns the CPU model. (6809 or 6309)
  - HPOINT(1) is planned to return whether the 6309 is running in Native Mode.
    (Currently, always returns zero.)
  - HPOINT(2) returns whether BASIC is running from RAM. (See HSET MEM)
  - HPOINT(3) returns the address of a useful data area for manipulating the
    new graphics-text mode (cursor blink, shape etc); see new file
    cocoroms/rom16kvars.asm.
  - HPOINT(4) returns the frequency of timer interrupts - 50 for PAL, 60 for
    NTSC - this is the value you need to divide TIMER/TIMERL by to get seconds
  - HPOINT(5) returns the address of the graphics-mode text font: 896 bytes
    for the 51-column version, followed by another 896 bytes for the "thin"
    (64-column) version.
- BASIC printer output redirected to DriveWire virtual printer (experimental),
  now with a flag in the aforementioned data area to disable redirection.
  (No BASIC interface to control it yet)
- Accepts binary constants with &B, just like &H and &O.
  - Also, these notations can yield values up to 2^32-1.
  - Ancient bug in &O (accepted 8 as a digit) fixed.
- Conversely, HEX$ now accepts values up to 2^32-1.
- ONERR, ERNO, and ERLIN work as expected.
  - Differently from the CoCo 3, ERNO and ERLIN can be examined in direct mode
    after the BASIC program ends.
- LPEEK and LPOKE work like PEEK and POKE but arguments are 16-bit unsigned
  integers, i.e., they affect addresses A and A+1. Example: LPEEK(&H68)
  returns the line number of the running BASIC program -- previously you needed
  to use 256*PEEK(&H68)+PEEK(&H69).
  - Additionally, both have now a block copy syntax: LPEEK$(A,N) returns a
    string with N characters with a copy of memory at address A. Likewise,
    LPOKE A,X$ pokes all bytes of X$ consecutively starting at address A.
- GOTO X may be used as an expression; it simply returns X. Useful for
  self-documenting programs that can be renumbered. Example:
  - 10 PRINT"TO CHANGE THE FUNCTION, EDIT LINE";GOTO 500
- Allows PCLEAR 0 for more RAM - instigated by an article by Allen Huffman:
  https://subethasoftware.com/2015/01/16/pclear-0-to-get-more-coco-basic-memory
  Requires PMODE 0. You should not, under any circumstances, do anything with
  graphics while in this mode or your BASIC program will be mercilessly
  clobbered.
- New BIN$ function that does exactly what you'd expect -- but, unlike HEX$,
  doesn't skip leading zeroes and always returns a 32-character string. Hence,
  for example, HEX$(5) returns "00000000000000000000000000000101".
- Special characters (numeric code above $7F) within string constants in BASIC
  programs now show correctly in listing. (Still doesn't work when saving a
  program with the ,A option)


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
hdbdos/runcoco.sh
hdbdos/pangram-pt.txt
