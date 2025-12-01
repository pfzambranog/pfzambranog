Use SCMBD
GO

Create or Alter Trigger dbo.TrinscatControlProcesosTbl
On     dbo.catControlProcesosTbl
After  Insert, update
AS

Set Ansi_nulls        On
Set Quoted_identifier On

Declare
  @w_idProcedimiento       Smallint,
  @w_procedimiento         Sysname,
  @w_procedimientoNotif    Sysname,
  @w_tablaLog              Sysname,
  @w_mensaje               Varchar(500);

Begin

   Select @w_procedimiento         = procedimiento,
          @w_tablaLog              = tablaLog,
          @w_procedimientoNotif    = procedimientoNotif
   From   Inserted
   If @@Rowcount = 0
      Begin
         Return
      End

   If Not Exists ( Select Top 1 1
                   From   sysobjects
                   Where  Uid  = 1
                   And    Type = 'P'
                   And    Name = @w_procedimiento)
      Begin
         Set @w_mensaje = 'El Procedimiento "' + @w_procedimiento + '" no Existe en la Base de Datos.: ' + Db_Name();

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   If @w_procedimientoNotif Is not Null
      Begin
         If Not Exists ( Select Top 1 1
                         From   sysobjects
                         Where  Uid  = 1
                         And    Type = 'P'
                         And    Name = @w_procedimientoNotif)
            Begin
               Set @w_mensaje = 'El Procedimiento de Notificación "' + @w_procedimientoNotif + '" no Existe en la Base de Datos.: ' + Db_Name();
      
               Raiserror (@w_mensaje, 16, 1)
               Rollback Transaction
               Return
            End
      End

   If Not Exists ( Select Top 1 1
                   From   sysobjects
                   Where  Uid  = 1
                   And    Type = 'U'
                   And    Name = @w_tablaLog)
      Begin
         Set @w_mensaje = 'La Tabla "' + @w_tablaLog + '" no Existe en la Base de Datos.: ' + Db_Name()

         Raiserror (@w_mensaje, 16, 1)
         Rollback Transaction
         Return
      End

   Return
End
Go

--
-- Comentarios.
--

Declare
   @w_valor          Varchar(1500) = 'Disparados de Insert / Update de la entidad catControlProcesosTbl.',
   @w_tabla          Sysname       = 'catControlProcesosTbl',
   @w_objeto         Sysname       = 'TrinscatControlProcesosTbl';


If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'Tr'
               And    b.name    = @w_objeto
               And    b.id      = a.major_id)

   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'Dbo',
                                      @level1type = 'table',
                                      @level1name = @w_tabla,
                                      @level2type = 'Trigger',
                                      @level2name = @w_objeto;

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'Dbo',
                                        @level1type = 'table',
                                        @level1name = @w_tabla,
                                        @level2type = 'Trigger',
                                        @level2name = @w_objeto;
   End
Go

