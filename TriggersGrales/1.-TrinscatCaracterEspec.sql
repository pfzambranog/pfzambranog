If Exists(Select Top 1 1
          From   Sysobjects
          Where  uid  = 1
          And    type = 'Tr'
          And    name = 'TrinscatCaracterEspec')
   Begin
      Drop Trigger TrinscatCaracterEspec
   End
GO

Create Trigger TrinscatCaracterEspec
On     dbo.catCaracterEspecTbl
After  Insert, Update

As

Declare
    @w_Caracter   Char(1),
    @w_ChrAscii   Smallint   

Begin

   Set Nocount On

   Select @w_Caracter    = Caracter,
          @w_ChrAscii    = ChrAscii 
   From   Inserted

   If Ascii(@w_Caracter)    = 39
      Begin
         Raiserror ('Código a Insertar no está permitido.', 16, 1) 
         Rollback Transaction    
      End

   If Ascii(@w_Caracter)   != @w_ChrAscii
      Begin
         Raiserror ('Código a Insertar no coincide con el Valor Ascii.', 16, 1) 
         Rollback Transaction
      End

   Set Nocount Off
   Return
End
Go 