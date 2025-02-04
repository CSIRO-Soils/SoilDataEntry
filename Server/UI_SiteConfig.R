################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Jan 30 14:37:10 2025                  ###
#####       Purpose : Set up the UI based on the supplied     ###
#####                 config parameters in the URL            ###
#####       Comments :                                        ###
################################################################# #


setupUIBasedOnConfigs <- function(config, url){

      if(!is.null(config)){
        
        html <-  tabsetPanel( type = "tabs", id='MainTabsetPanel',
                              Tab_DataIngestion_UI(),
                              Tab_SiteViewer_UI(), 
                              Tab_SitesFlatView(),
                              Tab_SitesSummary(),
                              #Tab_Admin(),
                              Tab_About()
        )
      }else{
        html <- HTML(paste0('<h1>Oops.....</h1>
                     <p>To use this tool you need to supply some setup parameters in the URL you used to get here.</p>
                     <p>eg. ', url, '?config=Aconfig&agencycode=AnAgencyCode&projectcode=aProject</p>
                     <BR><BR>
                     <p> Please get in touch with ross.searle@csiro.au for assistance</p>
                     ')
                     
                     
                     )
      }
      
}



setupHeaderBasedOnConfigs <- function(reqParams, configName, font, imageHeader, imageLogo, title){
      
        if(reqParams){
          t <- paste0( '<span style="color:white; font-size: 75px; font-family:', font  ,'; 
                        height: 120px; min-width: 100%; background-size:100% 100%; display: inline-block;
                        background-image: url(./Configs/', configName, '/' , imageHeader, ')" > &nbsp;&nbsp; 
                        <img src="./Configs/',configName, '/' , imageLogo, '", height=100px > ', 
                        title , '</span>') 
          }else{
            t <- paste0( '<span style="color:white; font-size: 75px; font-family:', 'Arial' ,'; height: 120px; min-width: 100%; background-size:100% 100%; display: inline-block;
                       background-image: url(./Configs/CSIRO/HeaderSoil.png)" > &nbsp;&nbsp; <img src="./images/csiro.png", height=100px > ', 'CSIRO Soil Data Entry Tool' , '</span>') 
          }
        return(t)
}



getListOfAvailableSites <- function(con, keys){
  
  if(keys$ProjectCode=='NSMP'){
    
    sql <- paste0("SELECT nat.[s_id] FROM [NatSoil].[project].[PROPOSED_SITES] nat JOIN [NSMP_Holding].[dbo].[SITES] nsmp
            ON nat.[agency_code] = nsmp.[agency_code] AND nat.[proj_code] = nsmp.[proj_code] AND nat.[s_id] = nsmp.[s_id]
            where nat.agency_code='", keys$AgencyCode, "' and nat.proj_code='", keys$ProjectCode, "'")
  }else{
    sql <- paste0("select s_id from sites where agency_code='", keys$AgencyCode, "' and proj_code='", keys$ProjectCode, "'")
  }
  
  sites <- OS$DB$Helpers$doQuery(con, sql)
  return(sites)
}
    
  

  
  
  
  
  