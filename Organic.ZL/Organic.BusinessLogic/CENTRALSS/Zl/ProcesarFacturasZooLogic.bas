Attribute VB_Name = "ProcesarFacturasZooLogic"
Global rango As Range, unicos As Range
Global objRequest As Object, i As Variant, s() As String, ejecutoProcesar As Boolean
Global n As Long, cant As Long, cantErrores As Long, response As Long
Global accessToken As String, idCliente As String, strResponse As String, strUrl As String, json As String, hastaColumna As String
Global jsonCabecera As String, jsonDetalle As String, cliente As String, bloque As String, mensajeProceso As String

Private Sub InicializarVariables()
    strUrl = "http://localhost:8008/api.Dragonfish/"
    idCliente = "ZOOSA"
    accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE5MTgzMTUyMzMsInVzdWFyaW8iOiJBRE1JTiIsInBhc3N3b3JkIjoiNDcwMWM4NmQ3MDY5NjU3NWFiZDY5YjM0MDEyZGI1NmY0YWU2MzY2N2U3ZWQwNmE2ZWU3OTJhYTAyZWY3Zjg3ZCJ9.DlG1aSBIYSZExeRNrfseuDtaO0b51ViwZgbWbz1phOw"
    Set objRequest = CreateObject("MSXML2.XMLHTTP")
    cant = 0
    response = 0
    cantErrores = 0
    strResponse = ""
    jsonCabecera = ""
    jsonDetalle = ""
    mensajeProceso = ""
End Sub

Sub Procesar()
    ejecutoProcesar = True
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
'fechaI = Now
    Autenticar
    If response = 200 Then
        CrearLibroErrores
        ProcesarColores_IMPO
        ProcesarArticulos_IMPO
        ProcesarFacturas_API
'fechaF = Now
        If cantErrores = 0 Then
            MsgBox mensajeProceso, vbInformation, "Proceso finalizado"
        Else
            If cantErrores = 1 Then
                mensajeProceso = mensajeProceso + "Hubo 1 error. Verifique Excel adjunto con el detalle del mismo."
            Else
                mensajeProceso = mensajeProceso + "Hubo " + CStr(cantErrores) + " errores. Verifique Excel adjunto con el detalle de los mismos."
            End If
            MsgBox mensajeProceso, vbInformation, "Proceso finalizado con errores"
        End If
        EliminarLibroErrores
    Else
        MsgBox "El servicio API de Dragonfish no está activo", vbCritical, "Couldn't connect to server"
    End If
'MsgBox CalcularTiempo(fechaI, fechaF), vbInformation, "Tiempo transcurrido"
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True
End Sub

Private Sub Autenticar()
    Application.StatusBar = "Autenticando servicio API. Un momento por favor..."
    InicializarVariables
    strUrl = strUrl + "Autenticar"

    With objRequest
        .Open "POST", strUrl, False
        .SetRequestHeader "Content-Type", "application/json"
        .Send ("{""IdCliente"":""" + idCliente + """,""JWToken"":""" + accessToken + """}")
        While objRequest.readyState <> 4
            DoEvents
        Wend
        response = .Status
        strResponse = .StatusText
    End With

    Set objRequest = Nothing
    If Not ejecutoProcesar Then MsgBox strResponse

    Application.StatusBar = ""
End Sub

Private Sub ProcesarColores_API()
    Application.StatusBar = "Procesando COLORES. Un momento por favor..."
    InicializarVariables
    strUrl = strUrl + "Color"

    If Not ejecutoProcesar Then CrearLibroErrores
    CrearExcelParaProcesarColoresEnMatriz

    For i = 0 To n
        If s(i) <> "" Then
            json = "{""Codigo"":""" + s(i) + """,""Descripcion"":""" + s(i) + """}"
            ProcesarJson (json)
            If response = 201 Then
                cant = cant + 1
            Else
                If Left(strResponse, 10) <> "El código " And Right(strResponse, 11) <> " ya existe." Then LoguearError ("Color")
            End If
        End If
    Next i

    Set objRequest = Nothing
    If ejecutoProcesar Then
        mensajeProceso = "Cantidad de COLORES ingresados en Dragonfish: " + CStr(cant) + Chr(13) + Chr(10)
    Else
        EliminarLibroErrores
        MsgBox "Cantidad de COLORES ingresados en Dragonfish: " + CStr(cant), vbInformation, "Proceso finalizado"
    End If

    Application.StatusBar = ""
End Sub

Private Sub ProcesarColores_IMPO()
    Application.StatusBar = "Procesando COLORES. Un momento por favor..."
    Workbooks.Add
    Application.Workbooks(1).Activate
    Set rango = Sheets("Datos para facturar").Range("F:F")
    Application.Workbooks(2).Activate
    Set unicos = Sheets(1).Range("A:A")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1
    Set unicos = Sheets(1).Range("B:B")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1

    ActiveWorkbook.SaveAs "C:\Dragonfish\Tmp\color.csv", xlCSV
    ActiveWorkbook.Close Savechanges:=False
    
    Dim wsh As Object
    Set wsh = VBA.CreateObject("WScript.Shell")
    wsh.Run "C:\Dragonfish\DRAGONFISH_Core.exe C:\Dragonfish\scripts\Importarcoloresparafacturar.txt", 1, True
    Set wsh = Nothing

    Application.Workbooks(1).Activate
    Application.StatusBar = ""
End Sub

Private Sub ProcesarArticulos_API()
    Application.StatusBar = "Procesando ARTICULOS. Un momento por favor..."
    InicializarVariables
    strUrl = strUrl + "Articulo"

    If Not ejecutoProcesar Then CrearLibroErrores
    CrearExcelParaProcesarArticulosEnMatriz
    
    For i = 0 To n
        If s(i, 0) <> "" Then
            json = "{""Codigo"":""" + s(i, 0) + """,""Descripcion"":""" + s(i, 1) + """,""Comportamiento"":2}"
            ProcesarJson (json)
            If response = 201 Then
                cant = cant + 1
            Else
                If Left(strResponse, 10) <> "El código " And Right(strResponse, 11) <> " ya existe." Then LoguearError ("Artículo")
            End If
        End If
    Next i
    
    Set objRequest = Nothing
    If ejecutoProcesar Then
        mensajeProceso = mensajeProceso + "Cantidad de ARTICULOS ingresados en Dragonfish: " + CStr(cant) + Chr(13) + Chr(10)
    Else
        EliminarLibroErrores
        MsgBox "Cantidad de ARTICULOS ingresados en Dragonfish: " + CStr(cant), vbInformation, "Proceso finalizado"
    End If
    
    Application.StatusBar = ""
End Sub

Private Sub ProcesarArticulos_IMPO()
    Application.StatusBar = "Procesando ARTICULOS. Un momento por favor..."
    Workbooks.Add
    Application.Workbooks(1).Activate
    Set rango = Sheets("Datos para facturar").Range("B:B")
    Application.Workbooks(2).Activate
    Set unicos = Sheets(1).Range("A:A")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1
    n = WorksheetFunction.CountA(Columns("A"))

    Application.Workbooks(1).Activate
    Set rango = Sheets("Datos para facturar").Range("G:G")
    Application.Workbooks(2).Activate
    Set unicos = Sheets(1).Range("B:B")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1
    
    Sheets(1).Select
    Range("C1").Select
    For i = 1 To n
        ActiveCell = 2
        ActiveCell.Offset(1, 0).Select
    Next i
    
    Set rango = Sheets(1).Range("A:C")
    Workbooks.Add
    Set unicos = Sheets(1).Range("A:C")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1

    ActiveWorkbook.SaveAs "C:\Dragonfish\Tmp\art.csv", xlCSV
    ActiveWorkbook.Close Savechanges:=False

    Application.Workbooks(2).Activate
    Application.Workbooks(2).Close
    
    Dim wsh As Object
    Set wsh = VBA.CreateObject("WScript.Shell")
    wsh.Run "C:\Dragon~1\DRAGONFISH_Core.exe C:\Dragonfish\scripts\Importararticulosparafacturar.txt", 1, True
    Set wsh = Nothing
    
    Application.Workbooks(1).Activate
    Application.StatusBar = ""
End Sub

Private Sub ProcesarFacturas_API()
    Application.StatusBar = "Procesando FACTURAS. Un momento por favor..."
    InicializarVariables
    strUrl = strUrl + "Factura"
    
    If Not ejecutoProcesar Then CrearLibroErrores
    CrearExcelParaProcesarFacturasEnMatriz
    cliente = s(0, 0)
    bloque = CStr(s(0, 4))
    
    For i = 0 To n - 1
        If s(i, 0) <> cliente Or (CStr(s(i, 4)) <> bloque) And jsonDetalle <> "" Then
            jsonCabecera = "{""Cliente"":""" + cliente + """,""FacturaDetalle"":["
            jsonDetalle = Mid$(jsonDetalle, 1, Len(jsonDetalle) - 1)
            ProcesarJson (jsonCabecera + jsonDetalle + "]}")
            If response = 201 Then cant = cant + 1 Else LoguearError ("Cliente y Bloque")
            jsonCabecera = ""
            jsonDetalle = ""
            cliente = s(i, 0)
            bloque = CStr(s(i, 4))
        End If
        jsonDetalle = jsonDetalle + "{""Articulo"":""" + s(i, 1) + """,""Color"":""" + s(i, 5) + """,""Cantidad"":" + Replace(s(i, 2), ",", ".") + ",""Precio"":" + Replace(s(i, 3), ",", ".") + "},"
    Next i
    
    Set objRequest = Nothing
    If ejecutoProcesar Then
        mensajeProceso = mensajeProceso + "Cantidad de FACTURAS ingresadas en Dragonfish: " + CStr(cant) + Chr(13) + Chr(10)
    Else
        EliminarLibroErrores
        MsgBox "Cantidad de FACTURAS ingresadas en Dragonfish: " + CStr(cant), vbInformation, "Proceso finalizado"
    End If
    
    Application.StatusBar = ""
End Sub

Private Sub CrearExcelParaProcesarColoresEnMatriz()
    CrearLibro
    
    Set rango = Sheets("Datos para facturar").Range("F:F")
    Application.Workbooks(3).Activate
    Set unicos = Sheets(1).Range("A:A")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1
    
    n = WorksheetFunction.CountA(Columns("A")) + 1
    hastaColumna = "A2:A" + CStr(n)
    Set unicos = Sheets(1).Range(hastaColumna)
    ReDim s(n) As String
    
    Application.Workbooks(1).Activate
    For fila = 1 To n
        s(fila - 1) = CStr(unicos(fila).Value)
    Next fila
    
    EliminarLibro
End Sub

Private Sub CrearExcelParaProcesarArticulosEnMatriz()
    CrearLibro
    
    Set rango = Sheets("Datos para facturar").Range("B:B")
    Application.Workbooks(3).Activate
    Set unicos = Sheets(1).Range("A:A")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos
    
    Application.Workbooks(1).Activate
    Set rango = Sheets("Datos para facturar").Range("G:G")
    Application.Workbooks(3).Activate
    Set unicos = Sheets(1).Range("B:B")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos
    
    Set rango = Sheets(1).Range("A:B")
    Set unicos = Sheets(1).Range("F:G")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos, Unique:=1
    
    n = WorksheetFunction.CountA(Columns("F")) + 1
    hastaColumna = "F2:G" + CStr(n)
    Set unicos = Sheets(1).Range(hastaColumna)
    ReDim s(n, 1) As String

    Application.Workbooks(1).Activate
    For fila = 1 To n
        For columna = 1 To 2
            s(fila - 1, columna - 1) = unicos(fila, columna).Value
        Next columna
    Next fila
    
    EliminarLibro
End Sub

Private Sub CrearExcelParaProcesarFacturasEnMatriz()
    CrearLibro
    
    Set rango = Sheets("Datos para facturar").Range("A:F")
    Application.Workbooks(3).Activate
    Set unicos = Sheets(1).Range("A:F")
    rango.AdvancedFilter Action:=xlFilterCopy, CopyToRange:=unicos

    n = WorksheetFunction.CountA(Columns("A"))
    hastaColumna = "A2:F" + CStr(n)
    Set unicos = Sheets(1).Range(hastaColumna)
    ReDim s(n - 1, 5) As String
    OrdenarExcel

    Application.Workbooks(1).Activate
    For fila = 1 To n
        For columna = 1 To 6
            s(fila - 1, columna - 1) = unicos(fila, columna).Value
        Next columna
    Next fila
    
    EliminarLibro
End Sub

Private Sub CrearLibroErrores()
    If Application.Workbooks.Count = 1 Then Workbooks.Add
    Application.Workbooks(1).Activate
End Sub

Private Sub EliminarLibroErrores()
    If cantErrores = 0 Then
        Application.Workbooks(2).Activate
        Application.Workbooks(2).Close
    End If
    Application.Workbooks(1).Activate
End Sub

Private Sub CrearLibro()
    Workbooks.Add
    Application.Workbooks(1).Activate
End Sub

Private Sub EliminarLibro()
    Dim librosAbiertos As Integer
    librosAbiertos = Application.Workbooks.Count
    For i = 3 To librosAbiertos
        Application.Workbooks(i).Activate
        Application.Workbooks(i).Close
    Next i
    Application.Workbooks(1).Activate
End Sub

Private Sub ProcesarJson(ByVal json As String)
    With objRequest
        .Open "POST", strUrl, False
        .SetRequestHeader "Content-Type", "application/json"
        .SetRequestHeader "Authorization", accessToken
        .SetRequestHeader "IdCliente", idCliente
        .Send (json)
        While .readyState <> 4
            DoEvents
        Wend
        response = .Status
        strResponse = .StatusText
    End With
End Sub

Private Sub OrdenarExcel()
    Sheets(1).Select
    Range("G1").Select
    For i = 1 To n
        ActiveCell = i
        ActiveCell.Offset(1, 0).Select
    Next i

    With Sheets(1).Sort
        .SortFields.Clear
        .SortFields.Add Key:=Range("A2:A" + CStr(n)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        .SortFields.Add Key:=Range("E2:E" + CStr(n)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        .SortFields.Add Key:=Range("G2:G" + CStr(n)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        .SetRange Range("A2:G" + CStr(n))
        .Header = xlGuess
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub

Private Function CalcularTiempo(ByVal Inicial As Date, ByVal Final As Date) As String
    Dim Años As Integer, Meses As Integer, Dias As Integer, Horas As Integer, Minutos As Integer, Segundos As Integer
    Años = 0: Meses = 0: Dias = 0: Horas = 0: Minutos = 0: Segundos = 0
    
    Segundos = Second(Final) - Second(Inicial)
    If Segundos < 0 Then
        Minutos = Minutos - 1
        Segundos = Segundos + 60
    End If
    
    Minutos = Minute(Final) - Minute(Inicial) + Minutos
    If Minutos < 0 Then
        Horas = Horas - 1
        Minutos = Minutos + 60
    End If
    
    Horas = Hour(Final) - Hour(Inicial) + Horas
    If Horas < 0 Then
        Dias = Dias - 1
        Horas = Horas + 24
    End If
    
    Dias = Day(Final) - Day(Inicial) + Dias
    If (Dias < 0) Then
        Dim ultimo As Integer
        ultimo = Day(DateSerial(Year(Inicial), Month(Inicial) + 1, 0))
        Meses = Meses - 1
        Dias = Dias + ultimo
    End If
    
    Meses = Month(Final) - Month(Inicial) + Meses
    If Meses < 0 Then
        Años = Años - 1
        Meses = Meses + 12
    End If
    
    Años = Year(Final) - Year(Inicial) + Años
    CalcularTiempo = Resultado(Años, Meses, Dias, Horas, Minutos, Segundos)
End Function

Private Function Resultado(Años As Integer, Meses As Integer, Dias As Integer, Horas As Integer, Minutos As Integer, Segundos As Integer) As String
    Resultado = Segundos & " Segundos"
    If Minutos > 0 Then Resultado = Minutos & " Minutos, " & Resultado
    If Horas > 0 Then Resultado = Horas & " Horas, " & Resultado
    If Dias > 0 Then Resultado = Dias & " Días, " & Resultado
    If Meses > 0 Then Resultado = Meses & " Meses, " & Resultado
    If Años > 0 Then Resultado = Años & " Años, " & Resultado
End Function

Private Sub LoguearError(ByVal tipo As String)
    cantErrores = cantErrores + 1
    Application.Workbooks(2).Activate
    Sheets(1).Select
    
    Range("A" + CStr(cantErrores)).Select
    ActiveCell = Format$(Date, "dd/mm/yyyy") + " " + CStr(Time)
    
    Range("B" + CStr(cantErrores)).Select
    ActiveCell = tipo

    Range("C" + CStr(cantErrores)).Select
    Select Case tipo
        Case "Color"
            ActiveCell = s(i)
        Case "Artículo"
            ActiveCell = s(i, 0)
        Case "Cliente y Bloque"
            ActiveCell = cliente + " - " + CStr(bloque)
    End Select
    
    Range("D" + CStr(cantErrores)).Select
    ActiveCell = strResponse
    
    ActiveCell.Offset(1, 0).Select
    Application.Workbooks(1).Activate
End Sub
