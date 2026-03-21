define class BuscadorDeProceso as zooSession
	protected function ApiStrToNum( tcNumber as string ) as long
		local nRes, nCont, nLength, cTmp, nPower

		nRes = 0
		nLength = len(tcNumber)
		nPower = 1

		for nCont = 1 to nLength
			nTmp = asc(substr(tcNumber, nCont, 1))
			nRes = nRes + (nTmp * nPower)
			nPower = nPower * 256
		next

		return(nRes)
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ApiNumToStr( tnNum as Long, tnLength as Integer ) as String
		local cRes, nCont, nTmp, lnMax

		nMax = (256 ^ tnLength) - 1

		if tnNum < 0
			tnNum = (2 ^ (tnLength * 8)) + tnNum
		endif

		tnNum = bitand(tnNum, nMax)

		cRes = ""
		for nCont = (tnLength - 1) to 0 step -1
			nTmp = int(tnNum / 256 ^ nCont)
			tnNum = tnNum - nTmp * (256 ^ nCont)
			cRes = chr(nTmp) + cRes
		next

		return(cRes)
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ListarProcesos( taProcesos ) as integer
		local nCount, nSnapShot, cBaseProcess, cProcess, nRes
		local cNombre, nProcessID, nThreads, nParentProcessID

		#define TH32CS_SNAPHEAPLIST   0x1
		#define TH32CS_SNAPPROCESS    0x2
		#define TH32CS_SNAPTHREAD     0x4
		#define TH32CS_SNAPMODULE     0x8
		#define TH32CS_SNAPALL        bitor(bitor(bitor(0x1, 0x2), 0x4), 0x8)
		#define TH32CS_INHERIT        0x80000000
		#define MAX_PATH              260

		declare long CreateToolhelp32Snapshot in Win32API long nFlags, long nID
		declare integer Process32First in Win32API long nHandle, string @cProcess
		declare integer Process32Next in Win32API long nHandle, string @cProcess
		declare integer CloseHandle in Win32API long nHandle

		cBaseProcess = ""
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + this.APINumtoStr(0, 4)
		cBaseProcess = cBaseProcess + space(MAX_PATH)
		cBaseProcess = this.APINumtoStr(len(cBaseProcess) + 4, 4) + cBaseProcess


		cProcess = cBaseProcess
		nSnapShot = CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0)
		nRes = Process32First(nSnapShot, @cProcess)
		nCount = 0

		do while nRes <> 0
			cNombre = alltrim(strtran(right(cProcess, 260), chr(0), ""))
			nProcessID = this.APIStrtoNum(substr(cProcess, 9, 4))
			nThreads = this.APIStrtoNum(substr(cProcess, 21, 4))
			nParentProcessID = this.APIStrtoNum(substr(cProcess, 25, 4))

			nCount = nCount + 1
			dimension taProcesos[nCount, 4]
			taProcesos[nCount, 1] = cNombre
			taProcesos[nCount, 2] = nProcessID
			taProcesos[nCount, 3] = nThreads
			taProcesos[nCount, 4] = nParentProcessID

			if val(os(3)) >= 5
				cProcess = cBaseProcess
			endif

			nRes = Process32Next(nSnapShot, @cProcess)
		enddo

		CloseHandle(nSnapShot)

		return(nCount)
	endfunc



	*-----------------------------------------------------------------------------------------
	function BuscarExe( tcPrograma as String ) as Long
		local laProcesos, nProcesos, nCont, lnId, i as Integer
		store 0 to lnId

		dimension laProcesos[1]
		nProcesos = this.ListarProcesos( @laProcesos )

		for i = 1 to alen( laProcesos, 1)
			if at( upper( tcPrograma), upper( laProcesos[ i, 1 ] ) ) > 0
				lnId = laProcesos[ i, 2 ]
				exit
			endif
		next

		return lnId
	endfunc
	

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeProcesos( tcPrograma as String ) as Integer
		local laProcesos, lnProcesos as Integer, lnCantidad as Integer, i as Integer, ;
			lcProceso as String

		dimension laProcesos[1]
		nProcesos = this.ListarProcesos( @laProcesos )
		lnCantidad = 0
		lcProceso = upper( alltrim( tcPrograma ) )
		for i = 1 to alen( laProcesos, 1)
			if lcProceso == upper( alltrim( laProcesos[ i, 1 ] ) )
				lnCantidad = lnCantidad + 1 
			endif
		next

		return lnCantidad
	endfunc	
enddefine
