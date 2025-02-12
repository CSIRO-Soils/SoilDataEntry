##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for the Site publishing tab   #####
#####       Comments :                                       #####
##################################################################


Tab_PublishSitesToNatSoil <- function() {
  
  tabPanel("Publish Sites",  icon = icon("upload", tags$style()),
           
        #HTML('<H1 style="font-size:40px;color:darkblue;font-weight:700">Publish Data</H1>'),
             HTML('<BR>'),
            fluidRow( column(width = 3, selectInput('wgtAuthoriser', "Person Authorising Site Data Publication", choices=c('Ross', 'Linda'))),
                      column(width = 9, HTML("<BR>"), shinyjs::disabled(actionButton('wgtPublishSitesBtn', 'Publish Selected Sites', class = "btn-success")))),
            HTML('<BR>
                           <p> The sites in the table below are currently in Draft form. 
                                They can be moved to Published form by selecting the check box/s and clicking on the "Publish Data" button. 
                                 Once the sites are published they can no longer be edited via this App</p>
                           '),
        
             HTML("<H3 style='color:orange;font-weight:700'>Draft Sites</H3>"), 
             reactableOutput("wgtHoldingSitesTable"), HTML("</span>") ,
             fluidRow( HTML('')),
            
             HTML('<H3 style="color:green;font-weight:700">Published Sites</H3>'),
             reactableOutput("wgtPublishedSitesTable"),
             
             HTML('<H3 style="color:red;font-weight:700">Sites Still To Do</H3>'),
             reactableOutput("wgtToDoSitesTable")
           
  )
           
}
