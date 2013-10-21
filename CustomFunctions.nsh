# Adeel Asghar [adeel.asghar@liu.se]
# 2013-Feb-22 14:03:46

# this function is called when user leaves the destination folder textbox. We use this function to find out if the destination folder has spaces or not.
Function DirectoryLeave
  # Call the CheckForSpaces function.
  Push $INSTDIR # Input string (install path).
  Call CheckForSpaces
  Pop $R0 # The function returns the number of spaces found in the input string.
  # Check if any spaces exist in $INSTDIR.
  StrCmp $R0 0 NoSpaces
    # Plural if more than 1 space in $INSTDIR.
    StrCmp $R0 1 0 +3
      StrCpy $R1 ""
    Goto +2
      StrCpy $R1 "s"
    # Show message box then take the user back to the Directory page.
    MessageBox MB_OK|MB_ICONEXCLAMATION "The Installaton directory \
    has $R0 space$R1.$\nPlease remove the space$R1."
    Abort
  NoSpaces:
FunctionEnd

# checks the spaces in a string and returns the number of spaces found.
Function CheckForSpaces
  Exch $R0
  Push $R1
  Push $R2
  Push $R3
  StrCpy $R1 -1
  StrCpy $R3 $R0
  StrCpy $R0 0
  loop:
    StrCpy $R2 $R3 1 $R1
    IntOp $R1 $R1 - 1
    StrCmp $R2 "" done
    StrCmp $R2 " " 0 loop
    IntOp $R0 $R0 + 1
  Goto loop
  done:
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

# takes the string and a divider. Splits the string based on the divider. 
Function GetLastPart
  Exch $R0 ; input
  Exch
  Exch $R1 ; divider str
  Push $R2
  Push $R3
  Push $R4
  Push $R5
   
  StrCpy $R2 -1
  StrLen $R4 $R0
  StrLen $R5 $R1
Loop:
  IntOp $R2 $R2 + 1
  StrCpy $R3 $R0 $R5 $R2
  StrCmp $R3 $R1 Chop
  StrCmp $R2 $R4 0 Loop
  StrCpy $R0 ""
  StrCpy $R1 ""
  Goto Done
Chop:
  StrCpy $R1 $R0 $R2
  IntOp $R2 $R2 + $R5
  StrCpy $R0 $R0 "" $R2
Done:
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1 ; before
  Exch
  Exch $R0 ; after
FunctionEnd

# callback function for GetDrives. Copies the drive name and drive type to $R0 and $R1 vars.
# if we push StopGetDrives then this callback function is only called once.
Function HardDiskDrives
  StrCpy $R0 $9
  StrCpy $R1 $8
  StrCpy $0 StopGetDrives
 
  Push $0
FunctionEnd

Function GetLocalTime
 
  # Prepare variables
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6
 
  # Call GetLocalTime API from Kernel32.dll
  System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r0'
  System::Call 'kernel32::GetLocalTime(i) i(r0)'
  System::Call '*$0(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)i \
  (.r4, .r5, .r3, .r6, .r2, .r1, .r0,)'
 
  # Day of week: convert to name
  StrCmp $3 0 0 +3
    StrCpy $3 Sunday
      Goto WeekNameEnd
  StrCmp $3 1 0 +3
    StrCpy $3 Monday
      Goto WeekNameEnd
  StrCmp $3 2 0 +3
    StrCpy $3 Tuesday
      Goto WeekNameEnd
  StrCmp $3 3 0 +3
    StrCpy $3 Wednesday
      Goto WeekNameEnd
  StrCmp $3 4 0 +3
    StrCpy $3 Thursday
      Goto WeekNameEnd
  StrCmp $3 5 0 +3
    StrCpy $3 Friday
      Goto WeekNameEnd
  StrCmp $3 6 0 +2
    StrCpy $3 Saturday
  WeekNameEnd:
 
  # Minute: convert to 2 digits format
    IntCmp $1 9 0 0 +2
      StrCpy $1 '0$1'
 
  # Second: convert to 2 digits format
    IntCmp $0 9 0 0 +2
      StrCpy $0 '0$0'
 
  # Return to user
  Exch $6
  Exch
  Exch $5
  Exch
  Exch 2
  Exch $4
  Exch 2
  Exch 3
  Exch $3
  Exch 3
  Exch 4
  Exch $2
  Exch 4
  Exch 5
  Exch $1
  Exch 5
  Exch 6
  Exch $0
  Exch 6
 
FunctionEnd

Function un.GetLocalTime
 
  # Prepare variables
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6
 
  # Call GetLocalTime API from Kernel32.dll
  System::Call '*(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2) i .r0'
  System::Call 'kernel32::GetLocalTime(i) i(r0)'
  System::Call '*$0(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)i \
  (.r4, .r5, .r3, .r6, .r2, .r1, .r0,)'
 
  # Day of week: convert to name
  StrCmp $3 0 0 +3
    StrCpy $3 Sunday
      Goto WeekNameEnd
  StrCmp $3 1 0 +3
    StrCpy $3 Monday
      Goto WeekNameEnd
  StrCmp $3 2 0 +3
    StrCpy $3 Tuesday
      Goto WeekNameEnd
  StrCmp $3 3 0 +3
    StrCpy $3 Wednesday
      Goto WeekNameEnd
  StrCmp $3 4 0 +3
    StrCpy $3 Thursday
      Goto WeekNameEnd
  StrCmp $3 5 0 +3
    StrCpy $3 Friday
      Goto WeekNameEnd
  StrCmp $3 6 0 +2
    StrCpy $3 Saturday
  WeekNameEnd:
 
  # Minute: convert to 2 digits format
    IntCmp $1 9 0 0 +2
      StrCpy $1 '0$1'
 
  # Second: convert to 2 digits format
    IntCmp $0 9 0 0 +2
      StrCpy $0 '0$0'
 
  # Return to user
  Exch $6
  Exch
  Exch $5
  Exch
  Exch 2
  Exch $4
  Exch 2
  Exch 3
  Exch $3
  Exch 3
  Exch 4
  Exch $2
  Exch 4
  Exch 5
  Exch $1
  Exch 5
  Exch 6
  Exch $0
  Exch 6
 
FunctionEnd