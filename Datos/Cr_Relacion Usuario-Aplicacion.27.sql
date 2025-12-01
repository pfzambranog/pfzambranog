

Declare
   @w_idUsuario                Integer,
   @PnIdAplicacion             Smallint,
   @PnIdAmbiente               Smallint,
   @PnIdOrigen                 Smallint,
   @PbIdEstatus                Bit,
   @w_idUsuarioAct             Integer,
   @PdFechaAct                 Datetime       = Null,
   @PsIpAct                    Varchar( 30)   = Null,
   @PsMacAddressAct            Varchar( 30)   = Null,
   @PnEstatus                  Integer        = 0,
   @w_sql                      Varchar(Max),
   @w_usuarios                 Varchar(Max),
   @PsMensaje                  Varchar(250),
   @w_registros                Integer,
   @w_secuencia                Integer,
   @w_comilla                  Char(1);


Begin
   Select @PnIdAplicacion  = 27,
          @PnIdAmbiente    = 1,
          @PbIdEstatus     = 1,
          @w_idUsuarioAct  = 1,
          @w_secuencia     = 0,
          @w_usuarios      = 'pedro.zambrano@3ti.mx', 
          @PdFechaAct      = Getdate(),
          @w_comilla       = Char(39),
          @PsIpAct         = dbo.Fn_BuscaDireccionIP(),
          @PsMacAddressAct = dbo.Fn_Busca_DireccionMAC();

   Create Table #TempUsuariosAplic
   (secuencia   Integer Not Null Identity (1, 1) Primary Key,
    idUsuario   Integer Not Null)

   Set @w_sql = 'Select a.idUsuario
                 From   Scsti.dbo.segUsuariosTbl a
                 Where  a.idEstatus    = 1'

   If @w_usuarios != ''
      Begin
         Set @w_usuarios = Replace(@w_usuarios, ' ', '')
         Set @w_usuarios = @w_comilla + Replace(@w_usuarios, ',', @w_comilla + ', '+ @w_comilla) + @w_comilla
         Set @w_sql = @w_sql + ' And claveUsuario In (' + @w_usuarios + ')'
      End
      
   Insert Into #TempUsuariosAplic
   (idUsuario)
   Execute(@w_sql)
   Set @w_registros = @@Identity

   While @w_secuencia < @w_registros
   Begin 
      Set @w_secuencia = @w_secuencia +  1;
      Select @w_idUsuario = idUsuario
      From   #TempUsuariosAplic
      Where  secuencia = @w_secuencia;
      If @@Rowcount = 0
         Begin
            Break
         End

      Select @PnEstatus = 0,
             @PsMensaje = Null 

      If Not Exists (Select Top 1 1
                     From   dbo.segRelAplicacionUsuarioTbl
                     Where  idAplicacion = @PnIdAplicacion
                     And    idUsuario    = @w_idUsuario)
         Begin
            Execute dbo.Spa_segRelAplicacionUsuarioTbl @PnIdUsuario      = @w_idUsuario, 
                                                       @PnIdAplicacion   = @PnIdAplicacion, 
                                                       @PbIdEstatus      = @PbIdEstatus, 
                                                       @PnIdUsuarioAct   = @w_idUsuarioAct, 
                                                       @PdFechaAct       = @PdFechaAct, 
                                                       @PsIpAct          = @PsIpAct, 
                                                       @PsMacAddressAct  = @PsMacAddressAct, 
                                                       @PnEstatus        = @PnEstatus Output,       
                                                       @PsMensaje        = @PsMensaje Output       
            If @PnEstatus <> 0
               Begin
                 Select @PnEstatus, @PsMensaje
               End
         End

      If Not Exists (Select Top 1 1    
                     From   dbo.segRelUsuarioAmbienteTbl    
                     Where  idUsuario    = @w_idUsuario    
                     And    idAplicacion = @PnIdAplicacion  
                     And    idAmbiente   = @PnIdAmbiente)  
         Begin
            Select @PnEstatus = 0,
                   @PsMensaje = Null

            Execute dbo.Spa_segRelUsuarioAmbienteTbl @PnIdUsuario      = @w_idUsuario,     
                                                           @PnIdAplicacion   = @PnIdAplicacion,     
                                                           @PnIdAmbiente     = @PnIdAmbiente,     
                                                           @PbEstatus        = @PbIdEstatus,     
                                                           @PnIdUsuarioAct   = @w_idUsuarioAct,    
                                                           @PdFechaAct       = @PdFechaAct,     
                                                           @PsIpAct          = @PsIpAct,     
                                                           @PsMacAddressAct  = @PsMacAddressAct,     
                                                           @PnEstatus        = @PnEstatus Output,           
                                                           @PsMensaje        = @PsMensaje Output           
            If @PnEstatus <> 0
               Begin
                 Select @PnEstatus, @PsMensaje
               End
         End

      Declare    
         C_Origen Cursor For    
         Select   idOrigen    
         From     dbo.segOrigenesConexionTbl
         Where    idEstatus     = 1
         And     (conexionMovil = 1
         Or       idOrigen      = 1)
         Order    By 1  
        
      Begin
           
         Open  C_Origen    
         While @@Fetch_Status  < 1  
         Begin    
            Fetch C_Origen Into @PnIdOrigen  
            If @@Fetch_Status <> 0  
               Begin    
                  Break
               End    
  
            If Not Exists (Select Top 1 1
                           From   dbo.segRelUsuarioOrigenConexionTbl
                           Where  idUsuario    = @w_idUsuario  
                           And    idAplicacion = @PnIdAplicacion 
                           And    idOrigen     = @PnIdOrigen)
               Begin
                  Select @PnEstatus = 0,
                         @PsMensaje = Null

                  Execute dbo.Spa_segRelUsuarioOrigenConexionTbl  @PnIdUsuario       = @w_idUsuario,     
                                                                        @PnIdOrigen        = @PnIdOrigen,     
                                                                        @PnIdAplicacion    = @PnIdAplicacion,    
                                                                        @PbIdEstatus       = @PbIdEstatus,     
                                                                        @PnIdUsuarioAct    = @w_idUsuarioAct,    
                                                                        @PdFechaAct        = @PdFechaAct,     
                                                                        @PsIpAct           = @PsIpAct,     
                                                                        @PsMacAddressAct   = @PsMacAddressAct,    
                                                                        @PnEstatus         = @PnEstatus Output,         
                                                                        @PsMensaje         = @PsMensaje Output  
            If @PnEstatus <> 0
               Begin
                 Select @PnEstatus, @PsMensaje
               End

               End

         End    
           
         Close      C_Origen    
         Deallocate C_Origen    
      End
    
   End  

   Drop Table #TempUsuariosAplic

   Return
End
Go