;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"U","V"/)
    g_data_model_path ="../data/esm_clim_UV.nc"
    g_data_era_path ="../data/Nudging-UV-ERA.nc"
    g_data_sample="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl/CLIM-Trans-2015.cam.h1.ESMc_add_028.U.hybrid.0101-0701.nc"
    output_fn ="/Users/zhenningli/data/CAL_SCSSM-2016/nudging_test/Nudging_UV_bias_correction.nc"
    g_font = 0.025
    g_level=200
  
    g_latN=40
    g_latS=0
    g_lonE=120
    g_lonW=45
    g_day_strt=75
    g_day_end=120

    ;Prepare the variables
    ctrl_in     = addfile (g_data_model_path, "r")   ; note the "s" of addfile
    var1  =ctrl_in->U
    var2  =ctrl_in->V
 
    obv_in     = addfile (g_data_era_path, "r")   ; note the "s" of addfile
    var1_obv  =obv_in->U
    var2_obv  =obv_in->V
 
    sample_in = addfile (g_data_sample,"r")
    var1_smp = sample_in->U(0:45,:,:,:)
    var2_smp = var1_smp


    var1:=var1(:,1:,:,:)
    var2:=var2(:,1:,:,:)
    dim0=dimsizes(var1)
    time0=dim0(0)

    var1_obv_int=f2fsh_Wrap(var1_obv,(/192,288/))
    
    var1_org=var1
    diff_var1=var1
    var1_obv_int(:,{g_latS:g_latN},{g_lonW:g_lonE})=dim_rmvmean_n_Wrap(var1_obv_int(:,{g_latS:g_latN},{g_lonW:g_lonE}),1)
    do ii=0, time0-1
       var1(ii,0:3,{3:42},:)=var1(ii,0:3,{3:42},:)+(/var1_obv_int(0:3,{0:40},:)/)
       var1(ii,4:5,{3:42},:)=var1(ii,4:5,{3:42},:)+(/var1_obv_int(5:6,{0:40},:)/)
       var1(ii,0:3,{0:3},:)=var1(ii,0:3,{0:3},:)+(/var1_obv_int(0:3,{-3:0},:)/)*0.5
       var1(ii,4:5,{0:3},:)=var1(ii,4:5,{0:3},:)+(/var1_obv_int(5:6,{-3:0},:)/)*0.5
    end do
    diff_var1=var1-diff_var1


    var1_smp(:,12:17,:,:)=(/var1/)
    var2_smp(:,12:17,:,:)=(/var2/)
    var1_smp&time=var1&time
    var2_smp&time=var2&time

    diff_var1:=dim_avg_n_Wrap(diff_var1(:,{g_level},:,:),0)
    var1_org_clim=dim_avg_n_Wrap(var1_org,0)
    var1_org_clim_lat = dim_avg_n_Wrap(var1_org_clim(:,{g_latS:g_latN},{g_lonW:g_lonE}),2)
    var1_clim=dim_avg_n_Wrap(var1,0)
    var1_clim_lat = dim_avg_n_Wrap(var1_clim(:,{g_latS:g_latN},{g_lonW:g_lonE}),2)


    var1_clim_max = var1_clim
    ;get max
    var1_dim :=dimsizes(var1_clim)
    do jj=0,var1_dim(2)-1
        var1_clim_max({g_level},{g_latS:g_latN},jj)=where(var1_clim({g_level},{g_latS:g_latN},jj) .lt.max(var1_clim({g_level},{g_latS:g_latN},jj)),var1_clim({g_level},{g_latS:g_latN},jj),1000.)
    end do

    var1_org_clim_max = var1_org_clim
    ;get max
    var1_org_dim :=dimsizes(var1_org_clim)
    do jj=0,var1_org_dim(2)-1
        var1_org_clim_max({g_level},{g_latS:g_latN},jj)=where(var1_org_clim({g_level},{g_latS:g_latN},jj) .lt.max(var1_org_clim({g_level},{g_latS:g_latN},jj)),var1_org_clim({g_level},{g_latS:g_latN},jj),1000.)
    end do



; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/g_day_comp_len/),graphic)
;  plot_V = new((/g_day_comp_len/),graphic)
;  plot_cn_max = new((/g_day_comp_len/),graphic)
;  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -5         ; set min contour level
 res@cnMaxLevelValF        = 5         ; set max contour level
 res@cnLevelSpacingF       = 1          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  ;res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
  res@gsnPaperOrientation = "portrait"
  ;res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = False   ; turn off the label bar
  ;res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 2 


  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpMaxLatF  =g_latN
  res@mpMinLatF  =g_latS
  res@mpMaxLonF  =g_lonE
  res@mpMinLonF  =g_lonW

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.
    
     ; now change the size of the tickmark labels
  res@tmXBMode="Explicit"
  res@tmXBValues=ispan(g_lonW,g_lonE,20)
  res@tmXBLabels=ispan(g_lonW,g_lonE,20)+"E"
  res@tmYLTickSpacingF = 10
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = ""
  res@gsnRightString = ""
       
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
 

  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 4 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/900./)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  res4=res3
  res4@cnLineColor="Grey"

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 

  g_fig_name="../fig/nudging/esm-era-bias-change-diff"
  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
  res@gsnLeftString="Mean U Diff after Change "+g_level+"hPa Day75-120"

  plot_sh= gsn_csm_contour_map(wks,diff_var1,res) ; create a default plot
  plot_cn_max = gsn_csm_contour(wks,var1_clim_max({g_level},:,:),res3)
  
  
  res3@cnLineColor      = "gray35"
  plot_cn_max2 = gsn_csm_contour(wks,var1_org_clim_max({g_level},:,:),res3)

  diff_var2=0
  xyres                 = True         ; xy plot mods desired
  xyres@vpHeightF        = .20          ; set width of second plot
  xyres@vpWidthF        = .25          ; set width of second plot
  xyres@tmXBMinorOn     = False        ; no minor tickmarks

  xyres@gsnDraw         = False        ; don't draw yet
  xyres@gsnFrame        = False        ; don't advance frame yet

  xyres@tmXBLabelFontHeightF=g_font        ; change font height
  xyres@gsnCenterString=""
  xyres@trYMinF         = g_latS 
  xyres@trYMaxF         = g_latN
  xyres@trXMinF         = -20
  xyres@trXMaxF         = 60
  xyres@xyLineThicknesses    = 3.0      ; line thicknesses
 
  xyres@tmXBOn              = True
  xyres@tmXBLabelsOn=True
  xyres@tmXBMode="Explicit"
  xyres@tmYRLabelsOn=True
  xyres@tmXBValues=ispan(-20,60,20)
  xyres@tmXBLabels=ispan(-20,60,20)
  
  xyres@tiXAxisString="U wind (m/s)"
  xyres@tiXAxisFontHeightF=g_font
  var1_clim_lat(2,:)=0
  plotxy = gsn_csm_xy(wks, var1_clim_lat(1:2,:), var1_clim_lat&lat, xyres)
  xyres@xyLineColor="gray"
  plotxy2 = gsn_csm_xy(wks, var1_org_clim_lat({g_level},:), var1_org_clim_lat&lat, xyres)
  overlay(plotxy,plotxy2)
  overlay(plot_sh,plot_cn_max)
  overlay(plot_sh,plot_cn_max2)
  newplot = gsn_attach_plots(plot_sh,(/plotxy/),res,xyres)
  draw(plot_sh)
  frame(wks)



;************************************************
; High Efficiency to Write the file
;************************************************
    print("Output...")

    output_fn="../data/esm_changed_clim_UV.nc"
;Get dimsize
    dims=dimsizes(var1_smp)
    ntime=dims(0)
    p_lvl=dims(1)
    nlat=dims(2)
    nlon=dims(3)
    
;Set fileoption    
    system("rm "+output_fn)
    fout = addfile(output_fn ,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"time","lev","lat","lon"/)
    dimSizes    =(/-1,p_lvl,nlat,nlon/)
    dimUnlim    =(/True,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"time",typeof(var1_smp&time),getvardims(var1_smp&time))
    filevardef(fout,"lev",typeof(var1_smp&lev),getvardims(var1_smp&lev))
    filevardef(fout,"lat",typeof(var1_smp&lat),getvardims(var1_smp&lat))
    filevardef(fout,"lon",typeof(var1_smp&lon),getvardims(var1_smp&lon))
    filevardef(fout,"U",typeof(var1_smp),getvardims(var1_smp))
    filevardef(fout,"V",typeof(var2_smp),getvardims(var2_smp))

;Define Attribute
    filevarattdef(fout,"time",var1_smp&time)
    filevarattdef(fout,"lev",var1_smp&lev)
    filevarattdef(fout,"lat",var1_smp&lat)
    filevarattdef(fout,"lon",var1_smp&lon)
    filevarattdef(fout,"U",var1_smp)
    filevarattdef(fout,"V",var2_smp)
    
    fout->time=(/var1_smp&time/)
    fout->lev=(/var1_smp&lev/)
    fout->lat=(/var1_smp&lat/)
    fout->lon=(/var1_smp&lon/)
    fout->U=(/var1_smp/)
    fout->V=(/var2_smp/)
    
end
