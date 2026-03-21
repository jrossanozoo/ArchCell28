*!*	 DRAGONFISH 2028
parameters tcRutaScriptEjecucion as String, tcLlamoLancelot as String, tcSerie as String, tcClave as String, tcSitio as String

SET CLEAR OFF
SET REFRESH TO 0

set procedure to 'Organic.Core.app' additive

do main with tcRutaScriptEjecucion, tcLlamoLancelot , tcSerie , tcClave , tcSitio 