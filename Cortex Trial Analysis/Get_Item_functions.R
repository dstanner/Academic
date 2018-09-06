get_item_num_spr <- function(df){
  
  # Initialize san output df for the precritical and item codes
  
  out <- data.frame(Subject = rep(df$Subject[1], with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Item = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    PrecritCode = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Index = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Bin = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Event_code = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)])))
                    )
  
  # Initialize index of where to put codes in the output df
  curr_out_ind <- 1
  
  for (ind in seq_along(df$index)) {
    
    # Whether or not we have the current critical code's precritical and item codes
    got_precrit <- FALSE
    got_item <- FALSE
    
    # Which index are we checking
    check_ind <- NA
    
    if (df$bin1[ind] %in% c(1:4)) { # only do this for critical codes
      
      out$Index[curr_out_ind] <- ind
      out$Bin[curr_out_ind] <- df$bin1[ind]
      out$Event_code[curr_out_ind] <- df$ecode[ind]
      
      check_ind <- df$index[ind - 1]
      
      # Loop until we get the item code
      while (got_item == FALSE) {
        
        # Loop until we get the precrit item
        while(got_precrit == FALSE){
          
          if (df$ecode[df$index == check_ind] == 251) {
              check_ind = df$index[check_ind - 1]
            } else {
              out$PrecritCode[curr_out_ind] <- df$ecode[df$index == check_ind]
              check_ind <- df$index[check_ind - 1]
              got_precrit <- TRUE # Exit the inner loop and return to the got_item loop
            } 
          }
        
        if (df$ecode[df$index == check_ind] == 251) {
          check_ind <- df$index[check_ind - 1]
          } else {
            out$Item[curr_out_ind] <- df$ecode[check_ind]
            curr_out_ind <- curr_out_ind + 1
            got_item <- TRUE
        }

      }
    }
  }
  return(out)
}

load_data <-function(subject_list, group){
  if (group == "SPR"){
    file_dir <- "./Event Files/"
    filenames <- paste0(file_dir, subject_list, "_event_bins.txt")
    skip <- 50
  } else if (group == "RSVP"){
    file_dir <- "./Event Files/"
    filenames <- paste0(file_dir, subject_list, "_AgrLexAux_s1_event.txt")
    skip <- 117
  }
  
  # Load th event lists to a list
  lines <- lapply(filenames, readLines)
  
  # Strip out the brackets
  lines <- sapply(lines, function(x) gsub("[[]", "", x))
  lines <- sapply(lines, function(x) gsub("\\]", "", x))
  
  # Turn into list of dataframes
  dfs <- lapply(lines, function(x) read.table(text = x, skip = skip, as.is = T, fill = T, col.names = col_names))
  names(dfs) <- paste0(subject_list)
  
  # Clean up and add subject numbers to each
  dfs <- lapply(dfs, function(x) x[,c(1, 3, 11)])
  for (i in 1:length(subject_list)){
    dfs[[i]]$Subject <- subject_list[i]
  }
  return(dfs)
}

get_item_num_rsvp <- function(df) {
  # Initialize san output df for the precritical and item codes
  
  out <- data.frame(Subject = rep(df$Subject[1], with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Item = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    PrecritCode = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Index = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Bin = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)]))),
                    Event_code = rep(NA, with(df, length(bin1[bin1 %in% c(1:4)])))
  )
  
  curr_out_ind <- 1
  
  for (ind in seq_along(df$index)) {
    if (df$bin1[df$index == ind] %in% c(1:4)){
      out$Bin[curr_out_ind] <- df$bin1[df$index == ind]
      out$Event_code[curr_out_ind] <- df$ecode[df$index == ind]
      out$Index[curr_out_ind] <- df$index[df$index == ind]
      out$PrecritCode[curr_out_ind] <- df$ecode[df$index == (ind - 1)]
      out$Item[curr_out_ind] <- df$ecode[df$index == (ind - 2)]
      curr_out_ind <- curr_out_ind + 1
    }
  }
  return(out)
}