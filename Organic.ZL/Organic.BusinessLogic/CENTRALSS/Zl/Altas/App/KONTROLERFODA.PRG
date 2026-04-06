define class KontrolerFODA as Din_KontrolerFODA OF Din_KontrolerFODA.PRG
			 
	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipEsUnRiesgo() as String
		local lret as String 
		text to lret noshow 
			Criterios - Considerar como riesgo si:
			- Probabilidad de ocurrencia: 1 - Grado de impacto: 1
			- Probabilidad de ocurrencia: 1 - Grado de impacto: 2
			- Probabilidad de ocurrencia: 2 - Grado de impacto: 1
		endtext		 		 
		return lret                    
	endfunc 
	
enddefine


