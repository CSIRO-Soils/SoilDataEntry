################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Jan 30 06:37:04 2025                  ###
#####       Purpose :                                         ###
#####       Comments :                                        ###
################################################################# #


formatFlatSheet <- function(ft){

ot <- reactable(ft, compact = TRUE, defaultPageSize = 20,showPagination = F, showPageInfo = FALSE, sortable = FALSE,
          
          striped = TRUE,
          highlight = TRUE,
          bordered = TRUE,
          theme = reactableTheme(
            borderColor = "#dfe2e5",
            stripedColor = "#f6f8fa",
            highlightColor = "#aed6f1",
            cellPadding = "0px 0px",
            style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif")
          ),
          
          
          defaultColDef = colDef(
            align = "right",
            
            headerStyle = list(
              #    `white-space` = "nowrap",
              #    #`transform-origin` = "50% 50%",
              #   transform = "rotate(-90deg)"
              #    `margin-top` = "10px",
              #    `margin-bottom` = "10px",
              #   # height = '150px',
              #    borderColor = "#ffffff",
              #   
              #   # minWidth = '800px',
              #   cellPadding = "20px 20px"
              # #  height = "7em"
              #   
            )
          ),
          
          columns = list(
            V1 = colDef(minWidth = 160, align = "right", name = "", cell = function(value, index) {div(div(style = list(fontWeight = 700), value))}),
            V2 = colDef(minWidth = 100, align = "left", name = ""), 
            V3 = colDef(maxWidth = 10, align = "center", name = ""),
            V4 = colDef(minWidth = 150, align = "right", name = "", cell = function(value, index) {div(div(style = list(fontWeight = 700), value))}),
            V5 = colDef(minWidth = 100, align = "left", name = ""),
            V6 = colDef(minWidth = 20, align = "left", name = ""),
            Horizon_Number = colDef(minWidth = 20, name = "Hor Num", align = "left"),
            Upper_Depth = colDef(minWidth = 40, name = "Upper Depth"),
            Lower_Depth = colDef(minWidth = 40, align = "center", name = "Lower-Depth"),
            
            Designation = colDef(minWidth = 50, align = "center", name = "Desig", cell = function(value) {div(div(style = list(color='red'), value))}),
            Desig_Suffix = colDef(minWidth = 20, align = "center", name = "Desig-Suf", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            Bdy_Distinctness = colDef(minWidth = 20, align = "center", name = "Bdy-Dist", cell = function(value) {div(div(style = list(color='red'), value))}),
            Bdy_Shape = colDef(minWidth = 20, align = "center", name = "Bdy-Shape", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            Texture = colDef(minWidth = 60, align = "center", name = "Texture", cell = function(value) {div(div(style = list(color='red'), value))}),
            Text_Qualifier = colDef(minWidth = 20, align = "center", name = "Text-Qual", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            Colour = colDef(minWidth = 60, align = "center", name = "Hor-Col"),
            
            Mott_Colour = colDef(minWidth = 20, align = "center", name = "Mot-Col", cell = function(value) {div(div(style = list(color='red'), value))}),
            Mott_Abun = colDef(minWidth = 20, align = "center", name = "Mot-Abun", cell = function(value) {div(div(style = list(color='red'), value))}),
            Mott_Contrast = colDef(minWidth = 20, align = "center", name = "Mot-Cont", cell = function(value) {div(div(style = list(color='red'), value))}),
            Mott_Size = colDef(minWidth = 20, align = "center", name = "Mot-Size ", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            CF_Abun = colDef(minWidth = 20, align = "center", name = "CF-Abun"),
            CF_Size = colDef(minWidth = 20, align = "center", name = "CF-Size"),
            CF_Shape = colDef(minWidth = 40, align = "center", name = "CF-Shape"),
            CF_Lithology = colDef(minWidth = 40, align = "center", name = "CF-Lith"),
            
            Structure_Grade = colDef(minWidth = 20, align = "center", name = "Str-Grade", cell = function(value) {div(div(style = list(color='red'), value))}),
            Structure_Size = colDef(minWidth = 20, align = "center", name = "Str-Size", cell = function(value) {div(div(style = list(color='red'), value))}),
            Structure_Type = colDef(minWidth = 40, align = "center", name = "Str-Type", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            Seg_Nature = colDef(minWidth = 20, align = "center", name = "Seg-Nat"),
            Seg_Abundance = colDef(minWidth = 20, align = "center", name = "Seg-Abun"),
            Seg_Size = colDef(minWidth = 20, align = "center", name = "Seg-Size"),
            Seg_Form = colDef(minWidth = 20, align = "center", name = "Seg-Form"),
            
            SWS = colDef(minWidth = 20, align = "center", name = "SWS", cell = function(value) {div(div(style = list(color='red'), value))}),
            Consistance = colDef(minWidth = 20, align = "center", name = "Consist", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            Cutan_Kind = colDef(minWidth = 20, align = "center", name = "Cut-Kind"),
            Cutan_Abun = colDef(minWidth = 20, align = "center", name = "Cut Abun"),
            Cutan_Distinct = colDef(minWidth = 20, align = "center", name = "Cut-Dist"),
            Cutan_Type = colDef(minWidth = 20, align = "center", name = "Cut-Type"),
            
            Pan_Cementation = colDef(minWidth = 20, align = "center", name = "Pan-Cem", cell = function(value) {div(div(style = list(color='red'), value))}),
            Pan_Continuity = colDef(minWidth = 20, align = "center", name = "Pan-Cont", cell = function(value) {div(div(style = list(color='red'), value))}),
            Pan_Structure = colDef(minWidth = 20, align = "center", name = "Pan-Str", cell = function(value) {div(div(style = list(color='red'), value))}),
            
            Root_Abund = colDef(minWidth = 20, align = "center", name = "Root-Abun"),
            Root_Size = colDef(minWidth = 20, align = "center", name = "Root-Size"),
            
            EC_Disp_Depth = colDef(minWidth = 50, align = "center", name = "FT-Depth", cell = function(value) {div(div(style = list(color='orange'), value))}),
            EC = colDef(minWidth = 50, align = "center", name = "EC", cell = function(value) {div(div(style = list(color='orange'), value))}),
            Dispersion = colDef(minWidth = 50, align = "center", name = "Dispersion", cell = function(value) {div(div(style = list(color='orange'), value))}),
            
            pH_Depth = colDef(minWidth = 50, align = "center", name = "pH-Depth", cell = function(value) {div(div(style = list(color='blue'), value))}),
            pH_Value = colDef(minWidth = 50, align = "center", name = "pH-Value", cell = function(value) {div(div(style = list(color='blue'), value))})
 
          )
)


return(ot)

}