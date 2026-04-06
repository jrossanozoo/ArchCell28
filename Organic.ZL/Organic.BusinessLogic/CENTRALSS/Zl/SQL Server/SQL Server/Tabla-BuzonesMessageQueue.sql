USE [ZL]
GO

/****** Object:  Table [ZL].[BuzonesMessageQueue]    Script Date: 09/18/2009 13:43:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[BuzonesMessageQueue]') AND type in (N'U'))
DROP TABLE [ZL].[BuzonesMessageQueue]
GO

USE [ZL]
GO

/****** Object:  Table [ZL].[BuzonesMessageQueue]    Script Date: 09/18/2009 13:43:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [ZL].[BuzonesMessageQueue](
      [id] [int] IDENTITY(1,1) NOT NULL,
      [maquina] [varchar](254) NULL,
      [buzon] [varchar](254) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
