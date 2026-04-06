-------------------------------------------------------------------------------
-- F. 1075
-------------------------------------------------------------------------------

-- =============================================
-- Author:		Daniel Correa
-- Create date: 14/01/2013
-- Description:	Trigger que dispara un mail para insert cuando se solicita
--              una aprobación de documento funcional
-- Modificacion: 21/02/2013 - Daniel Correa
-- =============================================
/****** Object:  Trigger [mailSoliciAprobDocFun]    Script Date: 01/28/2013 12:29:51 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[ZL].[mailSoliciAprobDocFun]'))
DROP TRIGGER [ZL].[mailSoliciAprobDocFun]
GO

create TRIGGER [ZL].[mailSoliciAprobDocFun] 
   ON  [ZL].[SOLAPRDOC] 
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE
  @TABLE AS VARCHAR(50)
  ,@REGISTRADOPOR AS VARCHAR(50) 
  ,@NUMERO AS INT;

  SET @TABLE = 'SOLAPRDOC' 
  SET @REGISTRADOPOR = (SELECT LTRIM(RTRIM(I.UALTAFW)) FROM INSERTED I) 
  SET @NUMERO = (SELECT I.NUMERO FROM INSERTED I)

  EXEC ZL.INSERTARLOGAVISOS 
    @REGPOR= @REGISTRADOPOR,
    @TABLA =@TABLE,
    @NROCOMPROB =@NUMERO;
END
