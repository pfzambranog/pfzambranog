Use SisArrendaCredito
Go

-- Objetivo:    Valida y Genera Objectos de Mantenimiento de la Base de Datos
-- Programador: Pedro Felipe Zambrano
-- Fecha:       21/11/2024
-- Versión:     1

--Declare
--   @PnEstatus             Integer      = 0,
--   @PsMensaje             Varchar(250) = Null;
--Begin
--   Execute dbo.Spp_ValidaMantenimientoBD @PnEstatus = @PnEstatus Output,
--                                         @PsMensaje = @PsMensaje Output;
--   Select @PnEstatus, @PsMensaje
--
--   Return
--End
--Go

Create Or Alter Procedure dbo.Spp_ValidaMantenimientoBD
  (@PnEstatus             Integer      = 0     Output,
   @PsMensaje             Varchar(250) = Null  Output)
As

Declare
   @w_error          Integer,
   @w_desc_error     Varchar(250),
   @w_sql            Varchar(Max),
   @w_ruta           varchar(100),
   @w_Archivo        Varchar(  150),
   @w_comilla        Char(1),
   @w_servidor       Sysname,
   @w_db_name        Sysname,
--
   @w_linea          Integer,
   @w_FileExistence  Integer,
   @w_objFSys        Integer,
   @w_OLEResult      Integer,
   @w_commando       Varchar(Max);

Begin
   Set Quoted_identifier Off
   Set Ansi_Nulls        Off
   Set Nocount           On
   Set Xact_Abort        On

   Select @PnEstatus        = 0,
          @PsMensaje        = Null,
          @w_comilla        = Char(39),
          @w_servidor       = @@ServerName,
          @w_db_name        = Db_name(),
          @w_archivo        = 'Spp_MantenimientoBD';

   Select @w_ruta = ibis
   from   dbo.parametro_rutas
   Where  id = 83;
   If @@Rowcount = 0
      Begin
         Select @PnEstatus = 9999,
                @PsMensaje = 'Error: El parametro de la ruta no existe';

         Set Xact_Abort    Off
         Return
      End

   If Not Exists ( Select Top 1 1
                   From   Sysobjects With (Nolock)
                   Where  Uid  = 1
                   And    Type = 'P'
                   And    Name = @w_archivo)
      Begin
         Execute sp_OACreate 'Scripting.FileSystemObject', @w_objFSys       Out
         Execute sp_OAMethod  @w_objFSys, 'FileExists',    @w_FileExistence Out, @w_archivo

         If @w_FileExistence = 1
            Begin
               Begin Try
                  Select   @w_commando = Concat('Call ', @w_ruta, '\Mantenimiento BD.bat')
                  Execute  master..xp_cmdshell @w_commando
               End  Try

               Begin Catch
                  Select  @w_Error      = @@Error,
                          @w_linea      = Error_line(),
                          @w_desc_error    = Substring (Error_Message(), 1, 200)

               End   Catch

               If Isnull(@w_Error, 0) != 0
                  Begin
                     Select @PnEstatus = @w_Error,
                            @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);

                     Set Xact_Abort    Off
                     Return
                  End

                Execute sp_OADestroy @w_objFSys
            End
         Else
            Begin
               Select @PnEstatus = 8888,
                      @PsMensaje = Concat('Archivo ', @w_archivo, ' No Existe')

               Set Xact_Abort    Off
               Return

            End
      End

   Begin Try
      Execute Spp_MantenimientoBD @PsDbName  = @w_db_name,
                                  @PnEstatus = @PnEstatus Output,
                                  @PsMensaje = @PsMensaje Output
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_linea      = Error_line(),
              @w_desc_error = 'Error.: ' +  Substring (Error_Message(), 1, 230)
   End   Catch

   If Isnull(@w_Error, 0) != 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = Concat('Error.: ', @w_Error, ' ', @w_desc_error, ' en Línea ', @w_linea);;

         Set Xact_Abort    Off
         Return
      End

   Set Xact_Abort    Off
   Return
End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Valida y Genera Objectos de Mantenimiento de la Base de Datos.',
   @w_procedimiento  Varchar( 100) = 'Spp_ValidaMantenimientoBD'


If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)

   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'Dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
