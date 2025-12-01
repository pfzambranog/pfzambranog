Use SCMBD
Go

Create Or Alter Trigger dbo.TrinscatControlProcesosTbl
On     dbo.catControlProcesosTbl
After  Insert, update
AS

Declare 
  @w_idProcedimiento       Smallint,
  @w_procedimiento         Sysname,
  @w_tablaLog              Sysname,
  @w_mensaje               Varchar(500);

Begin
   
   Select @w_procedimiento         = procedimiento,
          @w_tablaLog              = tablaLog
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


