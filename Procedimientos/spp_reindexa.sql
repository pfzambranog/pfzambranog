Create Or Alter Procedure spp_reindexa
  (@PsTabla      Sysname = Null)
As

Declare 
   @w_tabla       Sysname,
   @w_sql         NVarchar( 1500),
   @w_param       NVarchar(  750),
   @w_registros   Integer
  
Declare 
    C_Tablas Cursor For 
    Select Name 
    From   sys.tables a
    Where  name = Case When @PsTabla Is Null
                       Then a.name
                       Else @PsTabla
                  End
    Order  By 1
   
Begin

   Create Table #Temp
   (tabla          Sysname       Not Null,
    registros      Integer       Not Null Default 0,
    fechaInicio    Smalldatetime Not Null,
    fechatermino   Smalldatetime     Null,
    Primary Key (tabla))
    
   Open C_Tablas 
   While @@fetch_status < 1
   Begin
      Fetch C_Tablas Into @w_tabla 
      If @@Fetch_status != 0
         Begin
            Break
         End

      Select @w_sql   = 'Select @o_registros = Count(1) ' +
                        'From ' + @w_tabla,
             @w_param = ' @o_registros   Integer Output '
             
      Execute Sp_executeSQL @w_sql, @w_param, @o_registros = @w_registros Output
      
      Insert Into #Temp
      Select @w_tabla, @w_registros, Getdate(), Null
      
      DBCC Dbreindex(@w_Tabla,' ',90) 
      
      Update #Temp 
      Set     fechatermino = Getdate()
      
      
   End
   Close      C_Tablas 
   Deallocate C_Tablas
   
   Select *
   From   #Temp
   
   
   Return
   
End
Go

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que Realiza la reindexación de los indices.',
   @w_procedimiento  NVarchar(250) = 'spp_reindexa';

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
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure',
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure',
                                        @level1name = @w_procedimiento
   End
Go
