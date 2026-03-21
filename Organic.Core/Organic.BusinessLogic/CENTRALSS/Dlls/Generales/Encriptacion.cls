VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Encriptacion"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Public Clave As String

Public Function Encriptar(tsTexto As String) As String
    Dim lsCadenaEncriptada As String
    Dim loEncriptador As XceedEncryption
    Dim vaDecryptedText As Variant
    Dim lsClave As String
    
    lsClave = IIf(Len(Clave) = 0, "ClaveDura", Clave)
    
    Set loEncriptador = New XceedEncryption
    
    With loEncriptador
        .License ("CRY11-BZSX3-EG9H6-7KAA")
        Call .EncryptionMethod.SetSecretKeyFromPassPhrase(lsClave, 192)
        
        vaDecryptedText = StrConv(tsTexto, vbFromUnicode)
        lsCadenaEncriptada = BinaryToHex(.Encrypt(vaDecryptedText, True))
    End With
    
    Encriptar = lsCadenaEncriptada
End Function

Public Function DesEncriptar(tsTexto As String) As String
    Dim lsCadenaDesEncriptada As String
    Dim loEncriptador As XceedEncryption
    Dim vaDecrypted As Variant
    Dim lsClave As String
    
    lsClave = IIf(Len(Clave) = 0, "ClaveDura", Clave)
    
    Set loEncriptador = New XceedEncryption
    
    With loEncriptador
        .License ("CRY11-BZSX3-EG9H6-7KAA")
        Call .EncryptionMethod.SetSecretKeyFromPassPhrase(lsClave, 192)
        
        vaDecrypted = .Decrypt(HexToBinary(tsTexto), True)
        
        lsCadenaDesEncriptada = StrConv(vaDecrypted, vbUnicode)
    End With
    
    DesEncriptar = lsCadenaDesEncriptada
End Function

' Convert the variant specified to an hexadecimal representation, only if
' the variant is an array.
Private Function BinaryToHex(ByRef vaBinaryValue As Variant) As String

    Dim I As Long
    Dim sNewValue As String
    
    sNewValue = ""
    
    If (VarType(vaBinaryValue) And vbArray) = vbArray Then
        For I = 0 To LenB(vaBinaryValue) - 1
            sNewValue = sNewValue & Right("0" & Hex(CLng(vaBinaryValue(I))), 2)
        Next I
    End If
    
    BinaryToHex = sNewValue

End Function

' Convert the hexadecimal string to a byte array return as a variant
Private Function HexToBinary(ByRef sHexValue As String) As Variant

    Dim I As Long
    Dim NewValue() As Byte
    
    I = 0
    While I < Len(sHexValue)
        ReDim Preserve NewValue(I / 2)
        NewValue(I / 2) = Val("&H" & Mid$(sHexValue, I + 1, 2))
        I = I + 2
    Wend
    
    HexToBinary = NewValue

End Function
