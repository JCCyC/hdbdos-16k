##ISSUES:

- Errors in disk functions are sometimes not correctly intercepted - program
  silently ends instead.

##FUTURE FEATURE PLANS:

- ON BRK
- Option to boot in text mode:
  - Different ROM for default in text mode?
  - One hot key to swap the text mode at boot?
- Make the AND and OR operators accept values from -2^31 to 2^31-1.
  - Create a XOR operator
- Manipulate the sector offset (HDBHI/HDBLO).
- Allow GET #file,record# to obtain partial strings at EOF.
  - Plan: Patch from C3D3 onwards. Calculate how many bytes we're missing,
    subtract that from the record size, store that in a new DOS variable, read
    the bytes and pad the rest with binary zeroes.
- Ditto for LINE INPUT when the last line of a text file is missing the
  terminating newline character.
  - Alternatively, provide a function that calls LC597 until CINBFL is true.
- LOAD CHR$ to load an alternate text font for different code pages, either in
  its standard location when in RAM mode, or in user memory when in ROM mode.
- A subset of ANSI control codes for use as a terminal.
- RESTORE <line> like in other BASIC's. But the syntax will have to be
  something like RESTORE GOTO <line> in order to RENUM to be able to deal
  with it.
- As much as possible, alter ROM tables in hdbdos.asm instead of redefining
  duplicates in el.asm. (Vectors, tokens, command tables...)
- Check sanity of non-16k compilation of ROMs

##PIPE DREAMS:

- Enhance RENUM so it can renumber the first portion of a program, as opposed
  to only the second portion like it is currently in ECB.
- Make handling of string constants in BASIC code a bit less US-centric:
  - Come up with a way to edit programs within BASIC in a way that lets you
    type > $7F characters. Should work in direct mode too.
  - Make BASIC somehow understand text case and character normalization.
- Some kind of basic database-like search?
- Create a debug utility, including displaying a map of memory layout.

##WIP:

- Allow putting BASIC in 6309 Native Mode, i.e., change interrupt handling
  for different stack layout in NMI (simple) and IRQ (complicated) handlers.
