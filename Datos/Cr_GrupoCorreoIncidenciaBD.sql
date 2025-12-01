Use SCMBD
Go

Declare
   @w_idGrupoCorreo   Smallint,
   @w_idAplicacion    Smallint,
   @w_grupoCorreo     Varchar(20),
   @w_idUsuario       Integer,
   @w_idUsuarioAct    Integer,
   @w_fechaAct        Datetime,
   @w_ipAct           Varchar(30),
   @w_macAddressAct   Varchar(30);

Begin
   Select @w_idGrupoCorreo = 93,
          @w_grupoCorreo   = 'DBA',
          @w_idUsuarioAct  = 18,
          @w_idAplicacion  = 27,
          @w_fechaAct      = Getdate(),
          @w_ipAct         = dbo.Fn_BuscaDireccionIP(),
          @w_macAddressAct = dbo.Fn_Busca_DireccionMac();

   If Not Exists (Select Top 1 1
                  From   dbo.conGrupoReceptorCorreoTbl
                  Where  idGrupo = @w_idGrupoCorreo)
      Begin
         Insert Into dbo.conGrupoReceptorCorreoTbl
         (idGrupo,         codigoGrupo, descripcion,  idAplicacion,
          idProcedimiento, idEstatus,   idUsuarioAct, fechaAct,
          ipAct,           macAddressAct)
         Select @w_idGrupoCorreo,     @w_grupoCorreo, 'Reporte de Incidencias de BD',  @w_idAplicacion,
                Null idProcedimiento, 1 idEstatus,    @w_idUsuarioAct,                 @w_fechaAct,
                @w_ipAct,             @w_macAddressAct;
      End
   Else
      Begin
         Update dbo.conGrupoReceptorCorreoTbl
         Set    idAplicacion  = @w_idAplicacion,
                idEstatus     = 1,
                idUsuarioAct  = @w_idUsuarioAct,
                fechaAct      = @w_fechaAct,
                ipAct         = @w_ipAct,
                macAddressAct = @w_macAddressAct
         Where  idGrupo = @w_idGrupoCorreo
      End
      
   Set @w_idUsuario = 3

   If Not Exists (Select Top 1 1
                  From   dbo.conGrupoReceptorCorreoDetTbl
                  Where  idGrupo    = @w_idGrupoCorreo
                  And    idReceptor = @w_idUsuario)
      Begin
         If Not Exists (Select Top 1 1
                        From   dbo.segRelAplicacionUsuarioTbl  
                        Where  idAplicacion = @w_idAplicacion  
                        And    idUsuario    = @w_idUsuario)
            Begin
               Insert Into dbo.segRelAplicacionUsuarioTbl 
               (idUsuario, idAplicacion, idEstatus, idUsuarioAct,
                fechaAct,  ipAct,        macAddressAct)
               Select @w_idUsuario, @w_idAplicacion, 1 idEstatus,    @w_idUsuarioAct,
                      @w_fechaAct,  @w_ipAct,        @w_macAddressAct
            End

         Insert Into dbo.conGrupoReceptorCorreoDetTbl
         (idGrupo,  idReceptor, idEstatus, idUsuarioAct,
          fechaAct, ipAct,      macAddressAct)
         Select @w_idGrupoCorreo, @w_idUsuario, 1 idEstatus,    @w_idUsuarioAct,
                @w_fechaAct,      @w_ipAct,     @w_macAddressAct
      End

   Set @w_idUsuario = 15

   If Not Exists (Select Top 1 1
                  From   dbo.conGrupoReceptorCorreoDetTbl
                  Where  idGrupo    = @w_idGrupoCorreo
                  And    idReceptor = @w_idUsuario)
      Begin
         If Not Exists (Select Top 1 1
                        From   dbo.segRelAplicacionUsuarioTbl  
                        Where  idAplicacion = @w_idAplicacion  
                        And    idUsuario    = @w_idUsuario)
            Begin
               Insert Into dbo.segRelAplicacionUsuarioTbl 
               (idUsuario, idAplicacion, idEstatus, idUsuarioAct,
                fechaAct,  ipAct,        macAddressAct)
               Select @w_idUsuario, @w_idAplicacion, 1 idEstatus,    @w_idUsuarioAct,
                      @w_fechaAct,  @w_ipAct,        @w_macAddressAct
            End

         Insert Into dbo.conGrupoReceptorCorreoDetTbl
         (idGrupo,  idReceptor, idEstatus, idUsuarioAct,
          fechaAct, ipAct,      macAddressAct)
         Select @w_idGrupoCorreo, @w_idUsuario, 1 idEstatus,    @w_idUsuarioAct,
                @w_fechaAct,      @w_ipAct,     @w_macAddressAct
      End

   Set @w_idUsuario = 18

   If Not Exists (Select Top 1 1
                  From   dbo.conGrupoReceptorCorreoDetTbl
                  Where  idGrupo    = @w_idGrupoCorreo
                  And    idReceptor = @w_idUsuario)
      Begin
         If Not Exists (Select Top 1 1
                        From   dbo.segRelAplicacionUsuarioTbl  
                        Where  idAplicacion = @w_idAplicacion  
                        And    idUsuario    = @w_idUsuario)
            Begin
               Insert Into dbo.segRelAplicacionUsuarioTbl 
               (idUsuario, idAplicacion, idEstatus, idUsuarioAct,
                fechaAct,  ipAct,        macAddressAct)
               Select @w_idUsuario, @w_idAplicacion, 1 idEstatus,    @w_idUsuarioAct,
                      @w_fechaAct,  @w_ipAct,        @w_macAddressAct
            End

         Insert Into dbo.conGrupoReceptorCorreoDetTbl
         (idGrupo,  idReceptor, idEstatus, idUsuarioAct,
          fechaAct, ipAct,      macAddressAct)
         Select @w_idGrupoCorreo, @w_idUsuario, 1 idEstatus,    @w_idUsuarioAct,
                @w_fechaAct,      @w_ipAct,     @w_macAddressAct
      End
   Set @w_idUsuario = 29

   If Not Exists (Select Top 1 1
                  From   dbo.conGrupoReceptorCorreoDetTbl
                  Where  idGrupo    = @w_idGrupoCorreo
                  And    idReceptor = @w_idUsuario)
      Begin
         If Not Exists (Select Top 1 1
                        From   dbo.segRelAplicacionUsuarioTbl  
                        Where  idAplicacion = @w_idAplicacion  
                        And    idUsuario    = @w_idUsuario)
            Begin
               Insert Into dbo.segRelAplicacionUsuarioTbl 
               (idUsuario, idAplicacion, idEstatus, idUsuarioAct,
                fechaAct,  ipAct,        macAddressAct)
               Select @w_idUsuario, @w_idAplicacion, 1 idEstatus,    @w_idUsuarioAct,
                      @w_fechaAct,  @w_ipAct,        @w_macAddressAct
            End

         Insert Into dbo.conGrupoReceptorCorreoDetTbl
         (idGrupo,  idReceptor, idEstatus, idUsuarioAct,
          fechaAct, ipAct,      macAddressAct)
         Select @w_idGrupoCorreo, @w_idUsuario, 0 idEstatus,    @w_idUsuarioAct,
                @w_fechaAct,      @w_ipAct,     @w_macAddressAct
      End

   Set @w_idUsuario = 11661

   If Not Exists (Select Top 1 1
                  From   dbo.conGrupoReceptorCorreoDetTbl
                  Where  idGrupo    = @w_idGrupoCorreo
                  And    idReceptor = @w_idUsuario)
      Begin
         If Not Exists (Select Top 1 1
                        From   dbo.segRelAplicacionUsuarioTbl  
                        Where  idAplicacion = @w_idAplicacion  
                        And    idUsuario    = @w_idUsuario)
            Begin
               Insert Into dbo.segRelAplicacionUsuarioTbl 
               (idUsuario, idAplicacion, idEstatus, idUsuarioAct,
                fechaAct,  ipAct,        macAddressAct)
               Select @w_idUsuario, @w_idAplicacion, 1 idEstatus,    @w_idUsuarioAct,
                      @w_fechaAct,  @w_ipAct,        @w_macAddressAct
            End

         Insert Into dbo.conGrupoReceptorCorreoDetTbl
         (idGrupo,  idReceptor, idEstatus, idUsuarioAct,
          fechaAct, ipAct,      macAddressAct)
         Select @w_idGrupoCorreo, @w_idUsuario, 0 idEstatus,    @w_idUsuarioAct,
                @w_fechaAct,      @w_ipAct,     @w_macAddressAct
      End

End