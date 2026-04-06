-------------------------------------------------------------------------------
-- F. 1139
-------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[ZL].[mailAvisoReqDyC]'))
DROP TRIGGER [ZL].[mailAvisoReqDyC]
GO
-- =============================================
-- Author:		Daniel Correa
-- Create date: 14/01/2013
-- Description:	Trigger que dispara un mail cuando se de
--              alta un requerimiento para DyC
-- Modificado: 21/02/2013 - Daniel Correa
-- =============================================
CREATE TRIGGER [ZL].[mailAvisoReqDyC] 
   ON  [ZL].[DYCREQ] 
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE
    @TABLE AS VARCHAR(50)
    ,@REGISTRADOPOR AS VARCHAR(50) 
    ,@NUMERO AS INT;

  SET @TABLE = 'DYCREQ' 
  SET @REGISTRADOPOR = (SELECT LTRIM(RTRIM(I.REGPOR)) FROM INSERTED I) 
  SET @NUMERO = (SELECT I.CODIN FROM INSERTED I)

  EXEC ZL.INSERTARLOGAVISOS 
    @REGPOR= @REGISTRADOPOR,
    @TABLA =@TABLE,
    @NROCOMPROB =@NUMERO;
END
GO
