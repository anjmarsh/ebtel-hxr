FUNCTION aia_predict, logtdem, dem_cm5_cor, dem_cm5_tr, length=length, $
dns_pred_aia=dns_pred_aia, scaling=scaling, instr=instr, region=region, $
fill=fill, _extra=_extra

default, scaling, 3   ; scaling*flux is maximum permitted
default, instr, 'foxsi'
default, fill, 1.0 

savdir = '~/foxsi/ebtel-hxr-master/sav/'
default, length, 6d9  ; loop length in cm 

; Get observed / predicted AIA fluxes 
IF instr eq 'foxsi' THEN BEGIN
   dns_obs_aia = rd_tfile(savdir+'aia_dn_s_pixel.txt',7,-1)
   dns_obs_aia = average(float(dns_obs_aia[1:*,*]),2)
ENDIF ELSE IF instr eq 'nustar' THEN BEGIN
   restore, savdir+'aia_dn_s_pixel_nustar_regions.sav'
   IF ~isa(region) THEN BEGIN
      print, 'NuSTAR region must be specified'
      return, 0
   ENDIF
   dns_obs_aia = [[dns_obs_aia[region,0:4]],[dns_obs_aia[region,6]]]
ENDIF

wave = [94, 131, 171, 193, 211, 335]
dns_pred_aia = float(wave) 

for i=0, n_elements(wave)-1 do $
dns_pred_aia[i] = dem_aia(wave[i], logtdem, length, $
dem_cor=dem_cm5_cor, dem_tr=dem_cm5_tr, fill=fill, _extra=_extra)

ratio = dns_pred_aia / dns_obs_aia 
print, 'Ratios of AIA predicted to observed are '
print, ratio
ratio_test = ratio ge scaling 

IF total(ratio_test) gt 0 THEN return, 0 ELSE return, 1

END
