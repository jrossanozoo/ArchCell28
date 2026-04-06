/*
DECLARE @Serie AS CHAR(7)
DECLARE @TipoOperacion AS INT
DECLARE @Version AS VARCHAR(10)

IF @TipoOperacion = 3 --Restauracion de claves Lince
ENDIF
*/

SELECT
    ZL.Series.Nroserie AS 'Serie'
    ,ZL.Series.Serielin AS 'Serie Lince'
	,ZL.Razonsocial.Descrip AS 'Razon social'
	,ZL.Clientes.Cmpcodigo AS 'Cliente'
    ,zl.contact.[Codigo] AS 'Codigo contacto'
    ,LTRIM(RTRIM(zl.contact.[Pnom]))+ ' ' +LTRIM(RTRIM(zl.contact.[Snom]))+ ' ' +LTRIM(RTRIM(zl.contact.[Apell])) AS 'Contacto'
    ,ZL.MAILS.EMAIL AS 'Correo'
from 
	ZL.Series 
	LEFT JOIN ZL.Razonsocial ON ZL.Razonsocial.Cdir = ZL.Series.Cdir 
	LEFT JOIN ZL.Clientes ON ZL.Clientes.Cmpcodigo = ZL.Razonsocial.Cliente 
	LEFT JOIN ZL.MAILS ON ZL.MAILS.CLIENTE = ZL.Clientes.Cmpcodigo
	INNER JOIN ZL.[ASESRZMAIL] ON ZL.[ASESRZMAIL].EMAIL = ZL.MAILS.EMAIL 
		AND ZL.ASESRZMAIL.ACCMAIL = 6 --Notificaciones de Seguridad
		AND ZL.ASESRZMAIL.ACCION  = 1 --Alta
	LEFT JOIN ZL.Contact ON ZL.Contact.Codigo = ZL.MAILS.CONTACTO 
		AND ZL.Contact.Desacti = 0 --Contacto activo
WHERE
	ZL.Series.Nroserie = '205381'
	
