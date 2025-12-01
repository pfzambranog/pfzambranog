If Not Exists(Select top 1 1         
              From   msdb.dbo.sysmail_profile    
              Where  name = 'Objetos No Validos')  
   Begin
      Execute msdb.dbo.sysmail_add_account_sp   @account_name     = N'Objetos No Validos',      
                                                @description      = N'Objetos No Validos' ,      
                                                @email_address    = N'pfzambrano@gmail.com'  ,     
                                                @display_name     = 'Objetos No Validos',      
                                                @username         = '98de164ddb25e8ade1cbc8991e4f515a',    
                                                @password         = '6be98a492d78d18ac43a9d0ceffae1bf',     
                                                @port             = 587,
                                                @enable_ssl       = 1,                          
                                                @mailserver_name  = 'in-v3.mailjet.com'
	  
      Execute msdb.dbo.sysmail_add_profile_sp   @profile_name     = N'Objetos No Validos' ,      
                                                @description      = N'Objetos No Validos'      
            
      -- Add the account to the profile      
	  
      Execute msdb.dbo.sysmail_add_profileaccount_sp  @profile_name    = N'Objetos No Validos',      
                                                      @account_name    = N'Objetos No Validos',      
                                                      @sequence_number = 1 
   End
Go
