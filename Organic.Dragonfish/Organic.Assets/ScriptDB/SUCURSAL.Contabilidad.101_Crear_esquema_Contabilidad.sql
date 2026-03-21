if not exists( select name from sys.schemas where name = 'Contabilidad' )
	begin
		exec ('CREATE SCHEMA [Contabilidad] AUTHORIZATION [dbo]')
	end 

