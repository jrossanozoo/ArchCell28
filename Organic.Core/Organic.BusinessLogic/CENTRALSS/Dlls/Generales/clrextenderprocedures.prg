FUNCTION CreateRawExtender
LOCAL oResult
oREsult = CreateNetExtender()
oResult = SYS(3096,oResult)
RETURN oResult


FUNCTION GetCLRExtender
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
RETURN __oClrExtender

PROCEDURE SetCLRClassLibrary
LPARAMETERS m.tcAssembly, m.tlAdditive
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
RETURN __oClrExtender.SetClassLibrary(m.tcAssembly,m.tlAdditive)

PROCEDURE CLRFindAssembly
LPARAMETERS m.tcAssembly
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
RETURN __oClrExtender.oExtender.FindAssembly(m.tcAssembly)


FUNCTION CLRCreateZeroBasedArray
LPARAMETERS m.tcType, m.tnLength1, m.tnLength2
LOCAL oType, oArrayType, oResult, bMarshal, nLength
nLength = INT(m.tnLength1)
oType = CLRGetType(m.tcType)
oArrayType = CLRGetTypeReference("system.array")
bMarshal = __oCLRExtender.oExtender.bMarshalArrays
oArrayType.bMarshalArrays = .F.
IF PCOUNT() = 2 
	oResult = oArrayType.CreateInstance(oType,m.nLength)
ELSE
	oResult = oArrayType.CreateInstance(oType,m.nLength, INT(m.tnLength2))
ENDIF
__oCLRExtender.oExtender.bMarshalArrays = m.bMarshal
RETURN oResult

FUNCTION CLRCreateArray
LPARAMETERS m.tcType, m.tnLength1, m.tnLength2
LOCAL oType, oArrayType, oResult, bMarshal, nLength
nLength = INT(m.tnLength1)
oType = CLRGetType(m.tcType)
oArrayType = CLRGetTypeReference("system.array")
bMarshal = __oCLRExtender.oExtender.bMarshalArrays
oArrayType.bMarshalArrays = .F.
LOCAL aDims(PCOUNT()-1), aBounds(PCOUNT()-1)
IF PCOUNT() = 2 
	aDims(1) = m.tnLength1
	aBounds(1) = 1
ELSE
	aDims(1) = m.tnLength1
	aBounds(1) = 1
	aDims(2) = m.tnLength2
	aBounds(2) = 1
ENDIF
oResult = oArrayType.CreateInstance(oType,@aDims,@aBounds)
__oCLRExtender.oExtender.bMarshalArrays = m.bMarshal
RETURN oResult


FUNCTION CLRCreateEnum
LPARAMETERS m.tcType, m.tnValue
LOCAL bMarshal, oResult, oEnumType
bMarshal = __oCLRExtender.oExtender.bMarshalEnums
__oCLRExtender.oExtender.bMarshalEnums = .F.
oEnumType = CLRGetType(m.tcType)
oResult = CLRInvokeStaticMethod("System.Enum","ToObject",m.oEnumType,m.tnValue)
__oCLRExtender.oExtender.bMarshalEnums = m.bMarshal
RETURN m.oResult


FUNCTION CLRCreateCallback
	LPARAMETERS taParameterTypes, toReturnType, toHandler, tcMethod, tnCallingConvention
	LOCAL oResult
	oResult = __oCLRExtender.oExtender.CreateCallBack(@taParameterTypes,toReturnType, toHandler, tcMethod, tnCallingConvention)
	RETURN m.oResult


PROCEDURE CLRCreateFunctionPointer
	LPARAMETERS taTypes, toReturnType, toHandle, tcMethod, tnCallingConvention
	LOCAL nFunctionPointer, oDelegate
	nFunctionPointer = 0
	oDelegate = CLRCreateCallback(@taTypes,toReturnType,m.toHandler,m.tcMethod,0)
	IF ISNULL(oDelegate)
		ERROR "Error creating delegate"
	ENDIF
	nFunctionPointer = CLRInvokeStaticMethod("system.runtime.InteropServices.Marshal","GetFunctionPointerForDelegate",THIS.oDelegate)
	IF nFunctionPointer = 0
		ERROR "Could not create function pointer"
	ENDIF



FUNCTION CLRCreateObject
LPARAMETERS m.tcType, m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10
LOCAL nParameters, oResult
nParameters = PCOUNT()-1
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
DO CASE
	CASE m.nParameters = 0
		 oResult = __oClrExtender.CreateCLRObject(m.tcType)
	CASE m.nParameters = 1
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1)
	CASE m.nParameters = 2
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2)
	CASE m.nParameters = 3
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3)
	CASE m.nParameters = 4
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4)
	CASE m.nParameters = 5
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5)
	CASE m.nParameters = 6
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6)
	CASE m.nParameters = 7
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7)
	CASE m.nParameters = 8
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8)
	CASE m.nParameters = 9
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9)
	CASE m.nParameters = 10
		 oResult = __oClrExtender.CreateCLRObject(m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10)
ENDCASE
IF ISNULL(m.oResult)
	ERROR "Could not create object "+m.tcType+" possible reason: "+__oClrExtender.oExtender.ExceptionDescription
ENDIF
RETURN oResult

PROCEDURE FileToBytes
LPARAMETERS m.tcFile
IF NOT FILE(m.tcFile)
	RETURN NULL
ENDIF
LOCAL oStream, oResult
oStream = CLRInvokeStaticMethod("system.io.File","OpenRead",m.tcFile)
oResult = CLRCreateArray("system.byte",oStream.Length)
oStream.Read(oResult,0,oStream.Length)
oStream.Close()
RETURN oResult

FUNCTION BytesToFile
LPARAMETERS m.toBytes, m.tcFile
LOCAL oStream, nResult
oStream = CLRInvokeStaticMethod("system.io.file","OpenWrite",m.tcFile)
oStream.Write(m.toBytes,0,m.toBytes.Length)
nResult = oStream.Length
oStream.Close()
RETURN nResult

FUNCTION StringToBytes
LPARAMETERS m.tcString
LOCAL nLen, i, oResult
nLen = LEN(m.tcString)
IF nLen = 0
	RETURN NULL
ENDIF
oResult = CLRCreateArray("system.byte",nLen)
oResult.Copy(CREATEBINARY(m.tcString),oResult,nLen)
*oResult = CreateCLRArray("system.Byte",nLen)
*oTemp.Copy(oTemp,oResult,0)
RETURN oResult


FUNCTION CLRNewObject
LPARAMETERS m.tcType, m.tcAssembly, m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10
LOCAL nParameters, oResult
nParameters = PCOUNT()-2
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
IF "\" $ m.tcAssembly AND NOT FILE(m.tcAssembly)
	ERROR "Assembly: +"+m.tcAssembly+" does not exists"
ENDIF
DO CASE
	CASE m.nParameters = 0
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly)
	CASE m.nParameters = 1
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1)
	CASE m.nParameters = 2
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2)
	CASE m.nParameters = 3
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3)
	CASE m.nParameters = 4
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4)
	CASE m.nParameters = 5
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5)
	CASE m.nParameters = 6
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6)
	CASE m.nParameters = 7
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7)
	CASE m.nParameters = 8
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8)
	CASE m.nParameters = 9
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9)
	CASE m.nParameters = 10
		 oResult = __oClrExtender.NewCLRObject(m.tcType,m.tcAssembly,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10)
ENDCASE
IF ISNULL(m.oResult)
	ERROR "Could not create object "+m.tcType+" possible reason: "+__oClrExtender.oExtender.ExceptionDescription
ENDIF
RETURN oResult

PROCEDURE CreateCLRExtender
PUBLIC __oClrExtender
LOCAL cLibrary, cDir
cDir = JUSTPATH(JUSTPATH(SYS(16)))
m.cDir = ALLTRIM(SUBSTR(m.cDir, AT(" ", m.cDir,2)+1))
*!* cLibrary = m.cDir+"\Classes\netClrClasses.vcx"
IF "NETCLRCLASSES.VCX" $ SET("Classlib")
	__oClrExtender = CREATEOBJECT("baseCLRExtender")
ELSE
	cLibrary = m.cDir+"\Classes\netClrClasses.vcx"
	__oClrExtender = NEWOBJECT("baseCLRExtender",m.cLibrary)
ENDIF
__oClrExtender.cRootDir = m.cDir


PROCEDURE CLRGetType
LPARAMETERS m.tcType, m.tcAssembly
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
RETURN __oCLRExtender.LoadType(m.tcType,m.tcAssembly)

PROCEDURE CLRInvokeStaticMethod
LPARAMETERS m.tcType, m.tcMethod, m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10
LOCAL oType, nParameters, eResult
EXTERNAL ARRAY eResult
oType = CLRGetType(m.tcType)
nParameters = PCOUNT() - 2
IF VARTYPE(oType) = "O"
	DO CASE
		CASE m.nParameters = 0
			 eResult = __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod)
		CASE m.nParameters = 1
			 eResult = __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1)
		CASE m.nParameters = 2
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2)
		CASE m.nParameters = 3
			 eResult = __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3)
		CASE m.nParameters = 4
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4)
		CASE m.nParameters = 5
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5)
		CASE m.nParameters = 6
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6)
		CASE m.nParameters = 7
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7)
		CASE m.nParameters = 8
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8)
		CASE m.nParameters = 9
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9)
		CASE m.nParameters = 10
			 eResult =  __oCLRExtender.oExtender.InvokeMethodOnType(m.oType,m.tcMethod,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10)
	ENDCASE
	IF TYPE("eResult[1]") == "U" &&Not an array
		RETURN m.eResult
	ELSE
		LOCAL oResult, i
		oResult = CLRCreateArray("system::object",ALEN(eResult))
		FOR m.i = 1 TO ALEN(eResult)
			oResult.SetValue(m.eResult(m.i),m.i)
		ENDFOR
		RETURN m.oResult
	ENDIF
ELSE
	ERROR "Could not get Type reference to "+m.tcType
	RETURN NULL
ENDIF

FUNCTION CLRGetTypeReference
LPARAMETERS m.tcType, m.tcAssembly
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
RETURN __oCLRExtender.LoadTypeReference(m.tcType,m.tcAssembly)

FUNCTION CLRGetEnumValue
LPARAMETERS m.tcType, m.tcAssembly
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
LOCAL oEnum, cType, cMember, nResult
cType = LEFT(m.tcType,RAT(".",m.tcType)-1)
oEnum = __oCLRExtender.LoadTypeReference(m.cType,m.tcAssembly)
cMember = SUBSTR(m.tcType,RAT(".",m.tcType)+1)
nResult = EVALUATE("oEnum."+m.cMember)
RETURN m.nResult


FUNCTION CLRBindEvent
LPARAMETERS m.toSource, m.tcEvent, m.toHandler, m.tcDelegate,m.tlIndirect
LOCAL lInForm, oForm, oHandler, cDelegate, cHierarchy
lInForm = IsObjectInForm(m.toHandler)
IF m.lInform
	oForm = GetObjectForm(m.toHandler)
ELSE
*	oForm = CREATEOBJECT("HandlerSupportForm")
ENDIF
IF m.tlIndirect AND VARTYPE(m.oForm) = "O"
	oHandler = CREATEOBJECT("IndirectHandler")
	cHierarchy = SYS(1272,m.toHandler)
	IF "." $ m.cHierarchy
		m.cHierarchy = SUBSTR(m.cHierarchy,AT(".",m.cHierarchy)+1)
	ENDIF
	IF LOWER(m.oForm.Class) = "handlersupportform"
		m.cHierarchy = m.toHandler
	ENDIF
	oHandler.SetupEvent(m.toSource,m.oForm,m.cHierarchy,m.tcDelegate)
	m.cDelegate = "EventDelegate"
ELSE
	m.oHandler = m.toHandler
	m.cDelegate = m.tcDelegate
ENDIF
RETURN m.toSource.BindEvent(m.tcEvent,m.oHandler,m.cDelegate)


FUNCTION CLRUnbindEvents
LPARAMETERS m.toSource, m.tcEvent, m.toHandler, m.tcDelegate
LOCAL nResult
nResult = 0
IF COMCLASSINFO(m.toSource,5)="1"  && VFP Object is a Handler
	RETURN
ENDIF
IF PCOUNT() = 1
	nResult = m.toSource.UnBindEvents()
ENDIF
IF PCOUNT() = 4
	nResult = m.toSource.UnbindEvents(m.tcEvent,m.toHandler,m.tcDelegate)
ENDIF
RETURN m.nResult


FUNCTION IsObjectInForm
LPARAMETERS m.toInfo
IF NOT "." $ SYS(1272,m.toInfo)  && Object not contained so not in form
	RETURN .F.
ENDIF
LOCAL oParent
oParent = m.toInfo.Parent
IF LOWER(oParent.BaseClass) == "form"
	RETURN .T.
ENDIF
DO WHILE (NOT LOWER(m.oParent.BaseClass) == "form") AND "." $ SYS(1272,m.oParent)
	m.oParent = m.oParent.Parent
ENDDO
RETURN LOWER(oParent.BaseClass) == "form"

FUNCTION GetObjectForm
LPARAMETERS toInfo
LOCAL nOccurs, cHierarchy, m.i, oParent
cHierarchy  = SYS(1272,toInfo)
nOccurs = OCCURS(".",cHierarchy)
IF nOccurs = 0
	IF LOWER(m.toInfo.BaseClass)=="form"
	    RETURN m.toInfo && Es el form
	 ELSE
	 	RETURN NULL
	 ENDIF
ELSE
    oParent = toInfo
    FOR m.i = 1 TO nOccurs
        oParent = oParent.Parent
        IF LOWER(oParent.BaseClass)=="form"
        	RETURN oParent
        ENDIF
    ENDFOR
ENDIF
RETURN NULL

FUNCTION OleColorToWinformsColor
LPARAMETERS m.tnOleColor, m.tnAlpha
LOCAL oVFPColor
oVFPColor = CREATEOBJECT("vfpColor")
oVFPColor.ReadOleColor(m.tnOleColor)
IF VARTYPE(m.tnAlpha) = "N"
	oVFPColor.nAlpha = m.tnAlpha
ENDIF
RETURN m.oVFPColor.ToWinformsColor()

PROCEDURE CLRCompileActiveWindowToLibrary
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
__oClrExtender.CompileActiveWindow("library")

PROCEDURE CLRCompileActiveWindowToExe
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
__oClrExtender.CompileActiveWindow("exe")

PROCEDURE CLRCompileProject
IF TYPE("__oCLRExtender") = "U" OR ISNULL(__oClrExtender)
	DO CreateCLRExtender
ENDIF
__oClrExtender.CompileActiveProject()


DEFINE CLASS IndirectHandler AS CUSTOM
	oForm = NULL
	cHierarchy = ""
	cEventName = ""
	
	PROCEDURE SetupEvent
	LPARAMETERS m.toSource, m.toForm, m.tcHierarchy, m.tcEventName
	THIS.oForm = m.toForm
	THIS.cHierarchy = m.tcHierarchy
	THIS.cEventName = m.tcEventName
	= BINDEVENT(THIS.oForm,"Destroy",THIS,"FormDestroyed")

	PROCEDURE Destroy
	= CLRUnbindEvents(THIS)
	THIS.oForm = NULL
	
	PROCEDURE FormDestroyed
	= CLRUnbindEvents(THIS)
	THIS.oForm = NULL

	PROCEDURE EventDelegate
	LPARAMETERS m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10
	LOCAL nParameters, oHandler, cEventName
	oHandler = THIS.GetHandler()
	IF VARTYPE(m.oHandler) != "O" OR ISNULL(m.oHandler)
		RETURN 
	ENDIF
	cEventName = THIS.cEventName
	IF EMPTY(m.cEventName)
		RETURN
	ENDIF
	nParameters = PCOUNT()
	DO CASE
		CASE m.nParameters = 0
			 RETURN m.oHandler.&cEventName()
		CASE m.nParameters = 1
			 RETURN m.oHandler.&cEventName(m.teParam1)
		CASE m.nParameters = 2
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2)
		CASE m.nParameters = 3
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3)
		CASE m.nParameters = 4
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4)
		CASE m.nParameters = 5
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5)
		CASE m.nParameters = 6
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6)
		CASE m.nParameters = 7
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7)
		CASE m.nParameters = 8
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8)
		CASE m.nParameters = 9
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9)
		CASE m.nParameters = 10
			 RETURN m.oHandler.&cEventName(m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10)
	ENDCASE
	
	FUNCTION GetHandler
	LOCAL oForm
	oForm = THIS.oForm
	IF VARTYPE(THIS.cHierarchy) = "O" AND NOT ISNULL(this.cHierarchy)
		RETURN THIS.cHierarchy
	ELSE
		RETURN EVALUATE("m.oForm."+THIS.cHierarchy)
	ENDIF
	
ENDDEFINE


DEFINE CLASS HandlerSupportForm as Form
	PROCEDURE Destroy
		DODEFAULT()
		
ENDDEFINE

**************************************************
*-- Class:        vfpcolor (c:\archivos de programa\microsoft visual foxpro 8\tools\etecnologianetextender\samples\printing\libs\reporting.vcx)
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Time Stamp:   07/05/06 02:43:12 PM
*
DEFINE CLASS vfpcolor AS custom


	nred = 0
	ngreen = 0
	nblue = 0
	nalpha = 255
	Name = "vfpcolor"


	*-- Reads the ole color and fills the components accordingly
	PROCEDURE readolecolor
		LPARAMETERS tncolor
		THIS.nAlpha = 255
		THIS.nRed = BITAND(tnColor,255)
		THIS.nGreen = BITRSHIFT(BITAND(tnColor,BITLSHIFT(255,8)),8)
		THIS.nBlue = BITRSHIFT(BITAND(tnColor,BITLSHIFT(255,16)),16)
	ENDPROC


	*-- Returns a System.Drawing.Color
	PROCEDURE towinformscolor
		LOCAL oColor
		oColor = CLRInvokeStaticMethod("system.drawing.color","FromARGB",THIS.nalpha,THIS.nRed,THIS.nGreen,THIS.nBlue)
		RETURN oColor
	ENDPROC


ENDDEFINE
*
*-- EndDefine: vfpcolor
**************************************************
