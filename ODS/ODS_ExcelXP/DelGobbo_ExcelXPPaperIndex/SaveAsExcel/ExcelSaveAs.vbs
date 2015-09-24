'  Converts one or more files to Excel format
'
'  Execute the script using cscript, NOT wscript
'
'  Run the script without arguments to display the syntax
'
'  Password-protected workbooks are not supported

''' TODO: Add explicit object definitions


Option Explicit

On Error Resume Next

Dim ArgCount, ExitCode, i, intFileCount, xlFileFormat
Dim intFilesCreated, intFilesNotCreated, intSoundN
Dim arrFilesToProcess(), arrFilesCreated(), arrFilesNotCreated(), arrFilesNotCreatedError()
Dim boolDebug
Dim objExcel ' As Excel.Application.14
Dim objFile, objFiles, objFS
Dim strInputFilename, strMsg, strOutputFilename, strParentFolder, strPrompt2Continue, strReplace, _
    strSource, strSourceExt, strSuppressDialogs, strTargetExt, strTemp, strType, strVersion, strYN
Dim AddToMru, IgnoreReadOnlyRecommended, Password, ReadOnly, UpdateLinks, WriteResPassword

boolDebug  = False   ' Debugging flag
ExitCode   = 0
strTemp    = ""
strVersion = "1.0"   ' Software version
intSoundN  = 3       ' Number of beeps to play when an error is encountered

ArgCount = WScript.Arguments.Count

'  Show the syntax and exit if no called without arguments

If (ArgCount = 0) Then
  strMsg = ""
  ShowSyntax()
End If

'  Gather the values of the command line arguments

strSource          = WScript.Arguments.Named.Item("src")
strSourceExt       = WScript.Arguments.Named.Item("inext")
strTargetExt       = WScript.Arguments.Named.Item("outext")
strSuppressDialogs = WScript.Arguments.Named.Item("suppressdialogs")
strPrompt2Continue = WScript.Arguments.Named.Item("prompt2continue")
strTemp            = WScript.Arguments.Named.Item("debug")

If (UCase(strTemp) = "Y") Then boolDebug = True

'  Check for required values

If (strSource = "") Then 
  strMsg = vbCrLf & "ERROR: The SRC argument is required." & vbCrLf
  PlaySound intSoundN
	ShowSyntax()
End If

If (strTargetExt = "") Then 
  strMsg = vbCrLf & "ERROR: The OUTEXT argument is required." & vbCrLf
  PlaySound intSoundN
  ShowSyntax()
End If

'  Check the input values for other arguments

If (strSuppressDialogs <> "") And _
   (UCase(strSuppressDialogs) <> "Y" And UCase(strSuppressDialogs) <> "N") Then
  strMsg = "ERROR: Valid values of the SUPPRESSDIALOGS argument are ""Y"" or ""N""." & vbCrLf
  PlaySound intSoundN
  ShowSyntax()
End If 

If (strPrompt2Continue <> "") And _
   (UCase(strPrompt2Continue) <> "Y" And UCase(strPrompt2Continue) <> "N") Then
  strMsg = "ERROR: Valid values of the PROMPT2CONTINUE argument are ""Y"" or ""N""." & vbCrLf
  PlaySound intSoundN
  ShowSyntax()
End If 

If (strTemp <> "") And _
   (UCase(strTemp) <> "Y" And UCase(strTemp) <> "N") Then
  strMsg = "ERROR: Valid values of the DEBUG argument are ""Y"" or ""N""." & vbCrLf
  PlaySound intSoundN
  ShowSyntax()
End If 

'  Clear previous errors, if any

Err.Clear

'  Check the validity of the output file extension

If (UCase(strTargetExt) <> "XLS") And _
   (UCase(strTargetExt) <> "XLSX") Then 
  strMsg = "ERROR: """ & strTargetExt & """ is an invalid value for the OUTEXT argument.  Specify ""xls"" or ""xlsx"" for the output extension." & vbCrLf 
  ExitCode = 609201
  PlaySound intSoundN
  ShowError()
End If

'  Clear previous errors, if any

Err.Clear

'  Check to see if a valid file or a directory (folder) was specified
'  http://msdn.microsoft.com/en-us/library/6kxy1a51(VS.84).aspx

Set objFS = CreateObject("Scripting.FileSystemObject")

If (Err.Number <> 0) Then
  strMsg = "ERROR: Unable to create object Scripting.FileSystemObject." & vbCrLf 
  ExitCode = 609202
  PlaySound intSoundN
  ShowError()
End If

'  Clear previous errors, if any

Err.Clear

'  Determine if a file or folder was specified

strTemp = ""
strTemp = objFS.GetFolder(strSource)

If (strTemp <> "") Then
  strType = "folder"
Else
  strTemp = objFS.GetFile(strSource)
  If (strTemp <> "") Then 
    strType = "file"
  End If
End If

If (strType = "") Then
  strMsg = "ERROR: The source directory or file you specified, """ & strSource & """, does not exist." & vbCrLf
  ExitCode = 609203
  PlaySound intSoundN
  ShowError()
End If

'  Clear previous errors, if any

Err.Clear

'  Check for required values for converting an entire directory of files

If (strType = "folder" And strSourceExt = "") Then
  strMsg = "ERROR: The INEXT argument is required when converting files in a directory." & vbCrLf
  ExitCode = 609204
  PlaySound intSoundN
  ShowSyntax()
End If

If (boolDebug) Then 
  WScript.Echo "Argument values passed in:"

  WScript.Echo                                     "  /src:             """ & strSource & """"
  If (strSourceExt <> "")        Then WScript.Echo "  /inext:           " & strSourceExt
  WScript.Echo                                     "  /outext:          " & strTargetExt
  If (strPrompt2Continue  <> "") Then WScript.Echo "  /prompt2continue: " & strPrompt2Continue
  If (strSuppressDialogs  <> "") Then WScript.Echo "  /suppressdialogs: " & strSuppressDialogs 
  WScript.Echo
End If 

'  Add a trailing backslash to folder name, if omitted

If (strType = "folder") And (Mid(strSource, Len(strSource)) <> "\") Then 
  strSource = strSource & "\"
  If (boolDebug) Then WScript.Echo "Trailing backslash added to the source directory; the new value is: " & strSource & vbCrLf
End If

'  Determine the file or files to be processed

If (strType = "file") Then
  ReDim arrFilesToProcess(0)
  arrFilesToProcess(0) = strSource
  intFileCount = 1
Else
  '  Open the directory and collect the files with the specified extension
  
  Set objFiles = objFS.GetFolder(strSource).Files
  
  i = 0
  For Each objFile In objFiles
    If UCase(objFS.GetExtensionName(objFile.Name)) = UCase(strSourceExt) Then 
      ReDim Preserve arrFilesToProcess(i)
      arrFilesToProcess(i) = objFile.Name
      i = i + 1
    End If
  Next

  '  Clear previous errors, if any
  
  Err.Clear
  
  If (i = 0) Then
    strMsg = "ERROR: There are no """ & strSourceExt & """ files in the directory """ & strSource & """." & vbCrLf
    ExitCode = 609205
    PlaySound intSoundN
    ShowError()
  End If
  
  intFileCount = UBound(arrFilesToProcess) + 1
End If

If (boolDebug) Then
  If (intFileCount = 1) Then
    WScript.Echo "The following file will be processed:"
    WScript.Echo "  " & arrFilesToProcess(i)
  Else
    WScript.Echo "The following " & intFileCount & " files will be processed:"
    For i = 0 To UBound(arrFilesToProcess)
      WScript.Echo "  (" & i + 1 & ") " & arrFilesToProcess(i)
    Next
  End If

  WScript.Echo
End If

'  Prompt and allow to exit

If (UCase(strPrompt2Continue) <> "N") Then
  Prompt2Continue()
End If

If (boolDebug) Then WScript.Echo "Creating the Excel object." & vbCrLf

'  Clear previous errors, if any

Err.Clear

'  Excel Object Model Reference:
'  http://msdn.microsoft.com/en-us/library/ff194068.aspx

Set objExcel = Nothing
Set objExcel = CreateObject("Excel.Application")

If (boolDebug) Then WScript.Echo "objExcel=" & objExcel

If (Err.Number <> 0) Then
  strMsg = "ERROR: Unable to create object Excel.Application." & vbCrLf 
  ExitCode = 6092061
  PlaySound intSoundN
  ShowError()
End If

'  Make sure Excel is ready before proceeding

i = 0
If (objExcel <> "") Then
  Do While (Not objExcel.Ready)
    i = i + 1
    If (i > 5) Then 
      strMsg = "ERROR: Excel not ready after waiting for " & i-1 & " times." & vbCrLf 
      ExitCode = 6092062
      PlaySound intSoundN
      ShowError()
    End If
    WScript.Sleep 50
  Loop
End If

'  Set the Excel output type
'  Excel File Format Reference:
'  http://msdn.microsoft.com/en-us/library/ff198017.aspx

If (UCase(strTargetExt) = "XLS") Then
  xlFileFormat = -4143
ElseIf (UCase(strTargetExt) = "XLSX") Then
  xlFileFormat = 51
End If

If (boolDebug) Then
  WScript.Echo "The value of xlFileFormat for " & strTargetExt & " files is: " & xlFileFormat & vbCrLf
End If 

'  Loop over the files and save as the specified output type

intFilesCreated    = 0
intFilesNotCreated = 0

WScript.Echo

For i = 0 To UBound(arrFilesToProcess)
  If (strType = "file") Then
    strInputFilename  = arrFilesToProcess(i)
    strParentFolder   = objFS.GetFile(strInputFilename).ParentFolder
    If (Mid(strParentFolder, Len(strParentFolder)) = "\") Then
      strOutputFilename = strParentFolder & objFS.GetBaseName(strInputFilename) & "." & strTargetExt
    Else
      strOutputFilename = strParentFolder & "\" & objFS.GetBaseName(strInputFilename) & "." & strTargetExt
    End If
  Else
    strTemp           = strSource & arrFilesToProcess(i)
    strInputFilename  = objFS.GetFile(strTemp).ParentFolder & "\" & objFS.GetBaseName(strTemp) & "." & objFS.GetExtensionName(strTemp)
    strParentFolder   = objFS.GetFile(strInputFilename).ParentFolder
    If (Mid(strParentFolder, Len(strParentFolder)) = "\") Then
      strOutputFilename = strParentFolder & objFS.GetBaseName(strInputFilename) & "." & strTargetExt
    Else 
      strOutputFilename = strParentFolder & "\" & objFS.GetBaseName(strInputFilename) & "." & strTargetExt
    End If
  End If
  
  WScript.Echo "Converting file " & strInputFilename  & "  -- to --"
  WScript.Echo "                " & strOutputFilename
  
  '  Clear previous errors, if any

  Err.Clear

  '  Workbooks.Open(Filename, [UpdateLinks], [ReadOnly], [Format], [Password], [WriteResPassword], [IgnoreReadOnlyRecommended], [Origin], [Delimiter], [Editable], [Notify], [Converter], [AddToMru], [Local], [CorruptLoad])

  UpdateLinks               = 0
  ReadOnly                  = False
  Password                  = ""
  WriteResPassword          = ""
  IgnoreReadOnlyRecommended = True
  AddToMru                  = False

  objExcel.Workbooks.Open strInputFilename, UpdateLinks, ReadOnly, , Password, WriteResPassword, IgnoreReadOnlyRecommended, , , , , , AddToMru 
  
  If (Err.Number <> 0) Then 
    strMsg = vbCrLf & "Error opening the Excel workbook """ & strInputFilename & """."
    ExitCode = 609207
    PlaySound intSoundN
    ShowError()
  End If

  If (UCase(strSuppressDialogs) = "Y") Then 
    If (objExcel.Version >= 12) Then
      '  The Compatibility Checker dialog still shows - Alan says could be source code bug
      objExcel.ActiveWorkbook.CheckCompatibility = False
    End If
    objExcel.Application.DisplayAlerts = False  ' Handles both compatibility and overwrite dialogs
  Else 
    objExcel.Application.DisplayAlerts = True   ' Handles both compatibility and overwrite dialogs
  End If
  
  '  Clear previous errors, if any
  
  Err.Clear
  
  '  Create the output file in the specified format
  
  objExcel.ActiveWorkbook.SaveAs strOutputFilename, xlFileFormat
 
  '  Error 1004 - Cancel "Do you want to replace existing file" dialog
  '  Error 1004 - Cancel the "Compatibility Checker" dialog
  
  If (Err.Number = 0) Then
    ReDim Preserve arrFilesCreated(intFilesCreated)
    arrFilesCreated(intFilesCreated) = strOutputFilename
    intFilesCreated = intFilesCreated + 1
    WScript.Echo "File created."
  Else
    ReDim Preserve arrFilesNotCreated(intFilesNotCreated)
    ReDim Preserve arrFilesNotCreatedError(intFilesNotCreated)
    arrFilesNotCreated(intFilesNotCreated) = strOutputFilename
    strTemp = "Error number and description:" & Err.Number & ": " & Err.Description
    arrFilesNotCreatedError(intFilesNotCreated) = strTemp
    intFilesNotCreated = intFilesNotCreated + 1
    WScript.Echo "File NOT created.  " & strTemp
  End If

  If (Err.Number > 0 And Err.Number <> 1004) Then 
    strMsg = "Undetermined problem w/ SaveAs """ & strInputFilename & """."
    ExitCode = 609208
    PlaySound intSoundN
    ShowError()
  End If
  
  WScript.Echo
  
  '  Clear previous errors, if any
  
  Err.Clear
  
  '  Close the Excel workbook without saving changes, suppressing any alerts/dialogs

  objExcel.Application.DisplayAlerts = False

  objExcel.ActiveWorkbook.Close False
  
Next

'  Exit Excel

objExcel.Quit

'  Clean up
  
Set objExcel = Nothing
Set objFile  = Nothing
Set objFiles = Nothing
Set objFS    = Nothing

'  Print information about the files processed

PrintFilesProcessed()

WScript.Quit 0


' ----------------------------------------------------------------------------------------------

Sub Prompt2Continue
  
  Dim strYN
  
  '  Variables declared/defined in main program:
  '    boolDebug, intFileCount, ExitCode, strMsg, strSource, strSourceExt, strTargetExt, strType
  
  If (strType = "file") Then
    strMsg = "The file """ & strSource & """ will be converted to an " & strTargetExt & " file.  "
  Else 
   strMsg = intFileCount & " " & strSourceExt & " files in directory """ & strSource & """ will be converted to " & strTargetExt & " files.  "
  End If

  strMsg = strMsg & "Do you want to continue? [y | n] "
  
  WScript.StdOut.Write  strMsg
  strYN = WScript.StdIn.ReadLine
  
  If (boolDebug) Then WScript.Echo vbCrLf & "You replied: """ & strYN & """" & vbCrLf

  strYN = UCase(strYN)
  
  If (strYN = "N") Then 
    '  Clear previous errors, if any
    Err.Clear
    strMsg = "User requested exit." & vbCrLf 
    ExitCode = 609209
    PlaySound intSoundN
    ShowError()
  ElseIf (strYN <> "Y") Then 
    WScript.Echo "You must specify Y or N." & vbCrLf
    Prompt2Continue()
  End If
  
End Sub


' ----------------------------------------------------------------------------------------------

Function ReplaceOrPrompt

  '  Currently not used; may implement if/when Microsoft CheckCompability bug is fixed

  '  Variables declared/defined in main program:
  '    boolDebug, strType, strMsg 
 
  If (strType = "file") Then
    strMsg = "If the output file exists, do you want it to be automatically overwritten, or be prompted? [o | p] "
  Else
    strMsg = "If the output files exist, do you want them to be automatically overwritten, or be prompted one at a time? [o | p] "
  End If
  
  WScript.StdOut.Write strMsg
  ReplaceOrPrompt = WScript.StdIn.ReadLine
  
  If (boolDebug) Then WScript.Echo vbCrLf & "You replied: """ & ReplaceOrPrompt & """" & vbCrLf
  
  ReplaceOrPrompt = UCase(ReplaceOrPrompt)
  
  If (ReplaceOrPrompt <> "O") And _
     (ReplaceOrPrompt <> "P") Then 
    WScript.Echo "You must specify O or P." & vbCrLf
    ReplaceOrPrompt()
  End If
  
End Function


' ----------------------------------------------------------------------------------------------

Sub PlaySound (n)

  '  Play speaker beep n times

  Dim i

  For i = 1 To n
    WScript.echo Chr(7)
  Next


End Sub


' ----------------------------------------------------------------------------------------------

Sub ShowSyntax
  
  On Error Resume Next
 
  '  Variables declared/defined in main program:
  '    boolDebug, ExitCode, strMsg, strVersion

  If (ExitCode < 609200) Then 
    ExitCode = 609200
  End If

  WScript.Echo
  WScript.Echo

  If (strMsg <> "") Then
    WScript.Echo strMsg
    WScript.Echo
  End If

  WScript.Echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  WScript.Echo
  WScript.Echo  "Syntax Reference for ExcelSaveAs.vbs Version " + strVersion
  WScript.Echo
  WScript.Echo "Arguments:"
  WScript.Echo "========="
  WScript.Echo
  WScript.Echo "/src:""file_name"" | ""directory_path"""
  WScript.Echo "/outext:xls | xlsx"
  WScript.Echo "/inext:file_extension"
  WScript.Echo "/prompt2continue:y | n"
  WScript.Echo "/suppressdialogs:y | n"
  WScript.Echo "/debug:y | n"
  WScript.Echo
  WScript.Echo "/src:""file_name"" | ""directory_path"""
  WScript.Echo "  Source file or directory, enclosed in double quotes. Required."
  WScript.Echo
  WScript.Echo "/outext:xls | xlsx"
  WScript.Echo "  Output file extension and type. Required."
  WScript.Echo
  WScript.Echo "/inext:file_extension"
  WScript.Echo "  Input file extension and type.  Required if directory_path is specified for /src"
  WScript.Echo
  WScript.Echo "/prompt2continue:y | n"
  WScript.Echo "  Prompt to continue before execution starts.  The default value is y."
  WScript.Echo
  WScript.Echo "/suppressdialogs:y | n"
  WScript.Echo "  Suppress ALL Excel dialogs when creating the output file, including the"
  WScript.Echo "  dialog to prompt whether or not to overwrite an existing output file."
  WScript.Echo "  Use with caution.  The default value is n."
  WScript.Echo
  WScript.Echo "/debug:y | n"
  WScript.Echo "  Display additional debugging messages.  The default value is n."
  WScript.Echo
  WScript.Echo
  WScript.Echo "Examples:"
  WScript.Echo "========"
  WScript.Echo
  WScript.Echo "To convert a single file:"
  WScript.Echo "------------------------"
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir\myfile.xml"" /outext:xlsx"
  WScript.Echo
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir\myfile.htm"" /outext:xls"
  WScript.Echo
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir\myfile.csv"" /outext:xlsx"
  WScript.Echo
  WScript.Echo "To convert all files in a directory:"
  WScript.Echo "-----------------------------------"
  WScript.Echo
  WScript.Echo "All files with the extension specified by /inext are converted."
  WScript.Echo
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir"" /inext:xml /outext:xlsx"
  WScript.Echo
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir"" /inext:htm /outext:xls"
  WScript.Echo
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir"" /inext:csv /outext:xlsx"
  WScript.Echo
  WScript.Echo "To run in run in unattended (batch) mode:"
  WScript.Echo "----------------------------------------"
  WScript.Echo
  WScript.Echo "Use /prompt2continue:n and /suppressdialogs:y to suppress all user input."
  WScript.Echo
  WScript.Echo "  C:>CSCRIPT ExcelSaveAs.vbs /src:""C:\mydir"" /inext:xml /outext:xlsx /prompt2continue:n /suppressdialogs:y"
  WScript.Echo
 
  If (ArgCount > 0) Then
    WScript.Echo "See above for error message."
    WScript.Echo
  End If

  If (boolDebug) Then 
    WScript.Echo "Internal exit code is " & ExitCode & vbCrLf
  End If

  WScript.Echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  WScript.Echo

  WScript.Quit ExitCode
  
End Sub


' ----------------------------------------------------------------------------------------------

Sub ShowError

  '  Variables declared/defined in main program:
  '    ExitCode, objExcel, objFile, objFiles, objFS, strMsg

  If (Err.Number = 0 And ExitCode = 0) Then Exit Sub
    
  WScript.Echo strMsg
  
  WScript.Echo "VB Error Number: " & Err.Number & vbCrLf & _
    "VB Error Description: " & Err.Description  & vbCrLf & _
    "VB Source: " & Err.Source & vbCrLf
  
  On Error Resume Next
  
  WScript.Echo "Internal exit code is " & ExitCode & vbCrLf             
  
  '  Close the Excel workbook, suppressing any alerts/dialogs

  If (objExcel) Then 
    objExcel.Application.DisplayAlerts = False
    objExcel.ActiveWorkbook.Close
    objExcel.Quit
  End If
  
  '  Clean up
  
  Set objExcel = Nothing
  Set objFile  = Nothing
  Set objFiles = Nothing
  Set objFS    = Nothing

  '  Print information about the files processed

  PrintFilesProcessed()

  WScript.Quit ExitCode
End Sub


' ----------------------------------------------------------------------------------------------

Sub PrintFilesProcessed
  On Error Resume Next

  '  Variables declared/defined in main program:
  '   arrFilesCreated, arrFilesNotCreated, i, intFilesCreated, intFilesNotCreated, 

  If (intFilesCreated = 0 And intFilesNotCreated = 0) Then
    WScript.Echo "No files were processed." & vbCrLf
    Exit Sub
  End If

  If (intFilesCreated = 1) Then
    WScript.Echo "The following file was created:"
  ElseIf (intFilesCreated > 1) Then 
    WScript.Echo "The following " & intFilesCreated & " files were created:"
  End If
  
  For i = 0 To intFilesCreated
    WScript.Echo "  " & arrFilesCreated(i)
  Next

  If (intFilesNotCreated = 1) Then
    WScript.Echo vbCrLf & "The following file was NOT created:"
  ElseIf (intFilesNotCreated > 1) Then 
    WScript.Echo vbCrLf & "The following " & intFilesNotCreated & " files were NOT created:"
  End If
  
  For i = 0 To intFilesNotCreated
    WScript.Echo "  " & arrFilesNotCreated(i) & "  " & arrFilesNotCreatedError(i)
  Next
End Sub