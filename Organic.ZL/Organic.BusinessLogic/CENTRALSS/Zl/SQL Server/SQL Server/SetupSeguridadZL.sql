USE [ZL]
GO

-- CREAMOS UNA TABLA PARA GUARDAR LA CLAVE DEL APP_ROLE
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'ZL')
   EXEC sys.sp_executesql N'CREATE SCHEMA [ZL]' 
GO


IF OBJECT_ID('zl.jarl') IS NOT NULL
   DROP TABLE zl.jarl
GO   
 
CREATE TABLE zl.jarl (id varbinary(max))
go


-- creamos STORE PARA administrar los roles
if OBJECT_ID('zl.usp_jarl_i') is not null
   drop PROC zl.usp_jarl_i
go   


CREATE PROC zl.usp_jarl_i @id varchar(64)
with encryption
as
 -- lo usamos como insert y update ya que no puede haber 2 codigos  
  begin tran
    delete  from zl.jarl
  
     insert into zl.jarl
     select ENCRYPTBYPASSPHRASE('123',@id)
  
     commit tran
go  


if OBJECT_ID('ZL.usp_jarl_get') is not null
   drop PROC ZL.usp_jarl_get
go   
    
CREATE PROC ZL.usp_jarl_get @pss varchar(100)
with encryption
as
  if @pss = 'Mypassword'
   begin
        --select funciones.desencriptar192(id) from zl.jarl
      select CAST(DecryptByPassPhrase('123',ID) as varchar(150))   as pass
             from zl.jarl
          
   end
        
go  

-- Store para crear el log 

-- comprobamos que no exista el role

if OBJECT_ID('zl.usp_crear_role') is not null
   drop proc zl.usp_crear_role
go   

create proc zl.usp_crear_role
with encryption
as

SET NOCOUNT ON

begin try
  declare @idx as int
  declare @randomPwd as varchar(64)
  declare @rnd as float
  select @idx = 0
  select @randomPwd = N''
  select @rnd = rand((@@CPU_BUSY % 100) + ((@@IDLE % 100) * 100) + 
                (DATEPART(ss, GETDATE()) * 10000) + ((cast(DATEPART(ms, GETDATE()) as int) % 100) * 1000000))

  while @idx < 64

  begin
   select @randomPwd = @randomPwd + char((cast((@rnd * 83) as int) + 43))
   select @idx = @idx + 1
   select @rnd = rand()
  end

  declare @statement nvarchar(4000)

 begin tran

    IF EXISTS (select * from sys.database_principals 
               where name='ZLAPP' AND TYPE='A')
      BEGIN
        DROP APPLICATION ROLE [ZLAPP]
      END

    select @statement = N'CREATE APPLICATION ROLE [ZLAPP] WITH DEFAULT_SCHEMA = [dbo], ' + N'PASSWORD = N' + QUOTENAME(@randomPwd,'''')
    EXEC dbo.sp_executesql @statement


-- le damos control total al role de aplicacion

  GRANT CONTROL TO [ZLAPP] WITH GRANT OPTION 

  commit tran

  declare @pss varchar(64)
  set @pss = @randomPwd

  exec zl.usp_jarl_i @pss
  --exec DBO.jarl_i @pss
end try

-- control de error
begin catch  
  if @@trancount > 0 -- si hay transacciones activas
    begin
      rollback tran
    end
  
  SELECT  ERROR_NUMBER() AS NUMERO,
          ERROR_SEVERITY() AS SEVERIDAD,
          ERROR_STATE() AS STADO,
          ERROR_MESSAGE() AS MENSAJE  
end catch
go

-- le damos permisos a public para que pueda ejecutar

GRANT EXECUTE ON ZL.usp_jarl_get TO [public]

-- CREA EL ROLE

EXEC zl.usp_crear_role 

--insert into zl.jarl
--select ENCRYPTBYPASSPHRASE('123',@pss)

--select CAST(DecryptByPassPhrase('123',ID) as varchar(150))   as pass
--from zl.jarl

--exec ZL.USP_jarl_get 'Mypassword'


