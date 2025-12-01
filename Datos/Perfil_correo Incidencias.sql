Use msdb
Go

If Not Exists(Select top 1 1         
              From   msdb.dbo.sysmail_profile    
              Where  name = 'Incidencias BD')  
   Begin
      Execute msdb.dbo.sysmail_add_account_sp   @account_name     = N'Incidencias BD',      
                                                @description      = N'Incidencias BD' ,      
                                                @email_address    = N'servicioasistencias@3ti.mx'  ,     
                                                @display_name     = 'Incidencias BD',      
                                                @username         = 'f8023cccbf37021ccc3d8927de901def',    
                                                @password         = 'b5f36fd9dc8065b8ed70db3c68dfa246',     
                                                @port             = 587,
                                                @enable_ssl       = 1,                          
                                                @mailserver_name  = 'in-v3.mailjet.com'
	  
      Execute msdb.dbo.sysmail_add_profile_sp   @profile_name     = N'Incidencias BD' ,      
                                                @description      = N'Incidencias BD'      
            
      -- Add the account to the profile      
	  
      Execute msdb.dbo.sysmail_add_profileaccount_sp  @profile_name    = N'Incidencias BD',      
                                                      @account_name    = N'Incidencias BD',      
                                                      @sequence_number = 1 
   End
Go
