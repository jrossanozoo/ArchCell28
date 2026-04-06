ALTER PROCEDURE [ZL].[USP_InsertarRegcoddesact] 

(     @Coddesact varchar(40),
      @Nroserie varchar(7),
      @Usuario varchar(100),
      @Terminal varchar(30),
      @entradas numeric(4),
      @modulos varchar(6), 
      @idhard varchar(4),
      @franja varchar(4),
      @prom numeric(7,2),
      @errorNum varchar(6),
      @errorStr varchar(MAX),
      @CompAutoIDHW numeric(9,0),
      @Producto varchar(4), 
      @ipCliente varchar(45),
      @build varchar(5)

) 

with encryption
as
BEGIN  
 
declare @fecha as varchar(10), @hora as varchar(8), @hor as varchar(2), @min as varchar(2), @seg as varchar(2)
 
set @fecha = (SELECT CONVERT(CHAR(4),DATEPART(yyyy,GETDATE())) + CONVERT(CHAR(2),DATEPART(mm,GETDATE())) 

            + CONVERT(CHAR(2),DATEPART(dd,GETDATE())))

 
set @hor = funciones.padl(funciones.alltrim(CONVERT(CHAR(2),DATEPART(hh,GETDATE()))),'2','0')
set @min = funciones.padl(funciones.alltrim(CONVERT(CHAR(2),DATEPART(mi,GETDATE()))),'2','0')
set @seg = funciones.padl(funciones.alltrim(CONVERT(CHAR(2),DATEPART(ss,GETDATE()))),'2','0')

set @hora = @hor + ':' + @min + ':' + @seg

IF ( SUBSTRING(@Usuario, 1, 1) IN ('*', '@', '#'))
	BEGIN
		SET @Usuario = SUBSTRING(@Usuario, 2, 99);
	END


insert into  ZL.Regcoddesact 
             ( coddesact, fecha, hora, nroserie, usuario, terminal, entradas, modulos, idhard, franja, prom, errorNum, errorStr, autoriza, producto, ipCliente, build ) 
  values ( @Coddesact, getdate() , @hora , @Nroserie, @Usuario, @Terminal, @entradas, @modulos, @idhard, @franja, @prom, @errorNum, @errorStr, @CompAutoIDHW, @Producto, @ipCliente, @build )

 

END

GO



SET ANSI_NULLS OFF

GO

SET QUOTED_IDENTIFIER OFF

GO