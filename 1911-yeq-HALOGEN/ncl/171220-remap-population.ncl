;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"


begin
    
    ;grid file
    grid_fn="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/gridsys/GRIDCRO2D_3km"
    
    ;Output file 
    pdata_fn     ="../data/obv/population_output_D3.nc"  ; open output netCDF file

    ;Fig name
    g_fig_name="../fig/inner-prd"
    
    ;Fig title
    fig_title="Inner PRD Population"

    g_font=0.025
    ;Number of points
;    n_pts=5753
;---------------Read lat-lon config-------------------
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)
    grid_dim=dimsizes(lat2d) 
    
    ; Organize points in to var1
    pt_record  =   asciiread(data_file_name1,(/grid_dim(0),grid_dim(1)/),"float") ; get the first file's lat lon and value
    var1=lat2d
    var1=(/pt_record/)
    var1@long_name="population density"
    var1@units="person"
    var1!0="corx"
    var1&corx=ispan(1,110,1)
    var1!1="cory"
    var1&cory=ispan(1,152,1)

;************************************************
; High Efficiency to Write the file
;************************************************

;Get dimsize
    dims=dimsizes(var1)
    ncorx=dims(0)
    ncory=dims(1)
    
;Set fileoption    
    system("rm "+pdata_fn)
    fout = addfile(pdata_fn ,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"corx","cory"/)
    dimSizes    =(/ncorx,ncory/)
    dimUnlim    =(/False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"corx",typeof(var1&corx),getvardims(var1&corx))
    filevardef(fout,"cory",typeof(var1&cory),getvardims(var1&cory))
    filevardef(fout,"pop",typeof(var1),getvardims(var1))

;Define Attribute
    filevarattdef(fout,"pop",var1)
    
    fout->corx=(/var1&corx/)
    fout->cory=(/var1&cory/)
    fout->pop=(/var1/)

var1@lat2d=lat2d
var1@lon2d=lon2d

;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************
    wks = gsn_open_wks("x11",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

plot = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"NCV_jaisnd")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_ocean")
 gsn_define_colormap(wks,"matlab_hot")

 gsn_reverse_colormap(wks)


  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = 0          ; set min contour level
 res@cnMaxLevelValF        = 1e5          ; set max contour level
 res@cnLevelSpacingF       = 5e3          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
   res@cnFillMode           = "CellFill"
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  ;res@gsnLeftString = "11-07:00(UTC+8h)"
  ;res@gsnCenterString = "PM2.5_diff(no-gz_test)"
  res@gsnRightString = ""
  res@gsnStringFontHeightF = 0.03
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  ;res@lbLabelStride = 1


  ;res@mpMinLatF            = 23       ; zoom in on map
  ;res@mpMaxLatF            = 24
  ;res@mpMinLonF            = 112
  ;res@mpMaxLonF            = 113


  res@mpMinLatF            = min(var1@lat2d)        ; zoom in on map
  res@mpMaxLatF            = max(var1@lat2d)
  res@mpMinLonF            = min(var1@lon2d)
  res@mpMaxLonF            = max(var1@lon2d)


  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
  res@tmXBTickSpacingF = 2
  res@tmYLTickSpacingF = 2

res@tmXBLabelFontHeightF =g_font
res@tmYLLabelFontHeightF = g_font
res@gsnStringFontHeightF = g_font
res@tiMainFontHeightF= g_font
;res@lbLabelFontHeightF = 0.02
;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
res@tmXBMajorThicknessF = 2.0
res@tmYLMajorThicknessF = 2.0
res@tmXBMinorThicknessF = 2.0
res@tmYLMinorThicknessF = 2.0
res@tmBorderThicknessF = 2.0
res@tmYLMajorLengthF = 0.002


res@mpFillOn                = True
res@mpOutlineOn             = False  ; Use outlines from shapefile
res@cnFillDrawOrder         = "PreDraw"
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
;res@mpOceanFillColor        = "white"
;res@mpOutlineBoundarySets   = "NoBoundaries"

  plot = gsn_csm_contour_map(wks,var1,res) ; dim1 = 0 for lvl = 0
 
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

  chinamap = add_china_map(wks,plot,cnres)
  
  draw(plot)
  frame(wks)
end




