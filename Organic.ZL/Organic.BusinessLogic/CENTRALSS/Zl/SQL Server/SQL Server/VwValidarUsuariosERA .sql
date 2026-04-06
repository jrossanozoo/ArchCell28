ALTER  VIEW ZL.VwValidarUsuariosERA 

WITH ENCRYPTION, SCHEMABINDING

AS

select ccod as CodigoAgenteERA, descp as Nombre, 
		cmpemail as Mail,  pswera as Passw

from zl.legops

where activo= 1 and tipousu = '0003'
