## This script gets item numbers from the event files output by EEGLAB/ERPLAB for the RSVP participants.
## 
## The RSVP presentation scripts marked the first word of each sentence with the items number.
## The next word that was triggered was the precritical word, followed by the critical world.
## So the item number corresponds to the code received two codes before the critical world.
## This script extracts that information from the RSVP participants to pass on to the trial-level
## mixed models.
## 
## The SPR participants had trigger codes to mark the RT of each word they were presented with,
## so their processing logic will be somewhat different and involve a different script.
## 

col_names <- c("index", "bepoch", "ecode", "label", "onset", 
               "diff", "duration", "b_flags", "a_flags", "enable", "bin1", "bin2", "bin3", "bin4", "bin5", "bin6")
crit_bins <- c(1:4)

source("Get_Item_functions.R")

# Subject numbers to be included
subjects <- c(101, 102, 103, 105, 111, 112, 113, 114, 
              115, 116, 117, 118, 119, 120, 121, 122, 
              123, 124, 125, 126, 127, 128, 129, 131, 
              132, 133, 134, 135, 136, 137, 138, 140, 
              141, 142, 143, 145, 146, 147, 148, 149, 
              151, 152, 153, 155, 156, 157, 158, 159, 
              160, 161, 162, 163, 164, 165, 166, 167, 
              168, 170, 172, 175, 176, 177, 178, 179, 
              180, 182)

dfs <- load_data(subjects, "RSVP")

dfs_with_items <- lapply(dfs, get_item_num_rsvp)
events_df <- do.call(rbind, dfs_with_items)

# Remove the 5 error observations from ppt 138
events_df <- events_df[events_df$Item != 253,]

(as.data.frame(table(events_df$Subject))) # 120 observations from everyone but ppt 142, who had a trial missed due to recording error
(as.data.frame(table(events_df$Item))) # All items have 66 (n ppts) observations except item 49, which is the missing item for ppt 142


write.csv(events_df, "Trial_Item_information_RSVP.csv", row.names = F)
