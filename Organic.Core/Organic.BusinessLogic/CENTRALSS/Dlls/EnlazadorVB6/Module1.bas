Attribute VB_Name = "Module1"
'------------------------------------------------------------------------------
' Link.exe                                                          (27/Dic/05)
' Wrapper para el Link de VB6
' Basado en el código original de Ron Petrusha
' http://www.windowsdevcenter.com/pub/a/windows/2005/04/26/create_dll.html
'
' Versión reducida (sin escribir en un .LOG)                        (25/Ene/06)
' para publicar en mi sitio
'
' ©Guillermo 'guille' Som, 2005-2006
'------------------------------------------------------------------------------

Option Explicit

Public Sub Main()

    Dim SpecialLink As Boolean, fCPL As Boolean, fResource As Boolean
    Dim intPos As Integer
    Dim strCmd As String
    Dim strPath As String
    Dim strFileContents As String
    Dim strDefFile As String, strResFile As String
    
    Dim oFS As New Scripting.FileSystemObject
    Dim fld As Folder
    Dim fil As File
    Dim tsDef As TextStream
    
    strCmd = Command$
    
    ' Determine if .DEF file exists
    '
    ' Extract path from first .obj argument
    intPos = InStr(1, strCmd, ".OBJ", vbTextCompare)
    strPath = Mid$(strCmd, 2, intPos + 2)
    ' Esto solo vale para VB6
    intPos = InStrRev(strPath, "\")
    strPath = Left$(strPath, intPos - 1)
    ' Open folder
    Set fld = oFS.GetFolder(strPath)
    
    ' Get files in folder
    For Each fil In fld.Files
        If UCase$(oFS.GetExtensionName(fil)) = "DEF" Then
            strDefFile = fil
            SpecialLink = True
        End If
        If UCase$(oFS.GetExtensionName(fil)) = "RES" Then
            strResFile = fil
            fResource = True
        End If
        If SpecialLink And fResource Then Exit For
    Next
       
    ' Change command line arguments if flag set
    If SpecialLink Then
        
        ' Determine contents of .DEF file
        Set tsDef = oFS.OpenTextFile(strDefFile)
        strFileContents = tsDef.ReadAll
        If InStr(1, strFileContents, "CplApplet", vbTextCompare) > 0 Then
            fCPL = True
        End If
        
        ' Add module definition before /DLL switch
        intPos = InStr(1, strCmd, "/DLL", vbTextCompare)
        If intPos > 0 Then
            strCmd = Left$(strCmd, intPos - 1) & _
                  " /DEF:" & Chr$(34) & strDefFile & Chr$(34) & " " & _
                  Mid$(strCmd, intPos)
        End If
        
        ' Include .RES file if one exists
        If fResource Then
            intPos = InStr(1, strCmd, "/ENTRY", vbTextCompare)
            strCmd = Left$(strCmd, intPos - 1) & Chr$(34) & strResFile & _
                     Chr$(34) & " " & Mid$(strCmd, intPos)
        End If
        
        ' If Control Panel applet, change "DLL" extension to "CPL"
        If fCPL Then
            strCmd = Replace(strCmd, ".dll", ".cpl", 1, , vbTextCompare)
        End If
        
        strCmd = strCmd & " /LINK50COMPAT"
        
    End If
    
    Shell "linklnk.exe " & strCmd
    
    If Err.Number <> 0 Then
       ' Error al llamar al LINKer
       Err.Clear
    End If
    
End Sub

