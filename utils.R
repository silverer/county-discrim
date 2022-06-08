library(stringr)

fix_zips <- function(x){
  x = as.character(x)
  if(str_length(x)<4){
    return(paste0("00", x))
  }else if(str_length(x)<5){
    return(paste0("0", x))
  }else{
    return(x)
  }
}

fix_fips <- function(fip){
  if(is.na(fip)){
    return(NA)
  }
  
  else {
    fip = as.character(fip)
    return(str_pad(fip, width=5, 
                   pad="0", side="left"))
  }
}

fix_county_fip <- function(x){
  if(is.na(x)){
    return(x)
  }
  x = as.character(x)
  return(str_pad(x, width=3, 
                 pad="0", side="left"))
}

fix_state_fip <- function(x){
  if(is.na(x)){
    return(x)
  }
  x= as.character(x)
  return(str_pad(x, width=2, 
                 pad="0", side="left"))
}

paste_state_county_fip <- function(state_fip, county_fip){
  state_fip = fix_state_fip(state_fip)
  county_fip = fix_county_fip(county_fip)
  return(paste0(state_fip, county_fip))
}
