*!*	 DRAGONFISH 2028
parameters tcRutaScriptEjecucion as String, tcLlamoLancelot as String, tcSerie as String, tcClave as String, tcSitio as String

SET CLEAR OFF
SET REFRESH TO 0
LOCAL lcExePath
lcExePath = JUSTPATH(SYS(16,1))
SET DEFAULT TO (lcExePath)
SET PROCEDURE TO (lcExePath + "\Organic.Core.app") ADDITIVE

do main with tcRutaScriptEjecucion, tcLlamoLancelot , tcSerie , tcClave , tcSitio 		
