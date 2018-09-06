## This script gets item numbers from the event files output by EEGLAB/ERPLAB for the SPR participants.
## 
## The SPR presentation scripts marked the first word of each sentence with the items number.
## The precritical and critical word each received a condition code, but all words were marked
## with the SPR response code 251 each time the button was pushed in the SPR task to move on to
## the next word. So we have to ignore the 251s, and then get code two codes before the critical 
## word code.  This will be the item code.
## 
## This script extracts that information from the SPR participants to pass on to the trial-level
## mixed models.
## 
## The RSVP participants had a different trigger coding scheme (no RT codes), so they are processed
## in another script.
## 

col_names <- c("index", "bepoch", "ecode", "label", "onset", 
               "diff", "duration", "b_flags", "a_flags", "enable", "bin1", "bin2", "bin3", "bin4", "bin5", "bin6")
crit_bins <- c(1:4)


subjects <- c(301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 
              317, 318, 320, 321, 322, 323, 324, 326, 327, 329, 330, 331, 333, 335, 336, 337, 
              338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 349, 351, 352, 353, 354, 355)

# Load the file with necessary functions I wrote to organize the data
source("Get_Item_functions.R")

dfs <- load_data(subjects, "SPR")

dfs_with_items <- lapply(dfs, get_item_num_spr)

output_df <- do.call(rbind, dfs_with_items)

# Checking the output df showed one error in the item code for ppt 318.
# One of the RT codes was mistakenly 255 instead of 251 (I am not sure why).
# Inspection of the individual's event file showed that the correct item
# code should be 68, and not 255. Fix that here.

output_df$Item[output_df$Subject == 318 & output_df$Index == 2735] <- 68

# Final checks
sum(output_df$Item > 120) # 0, because the max item code was 120
(item_table <- as.data.frame(with(output_df, table(Item)))) # All are 48, as they should be
(sub_table <- as.data.frame(with(output_df, table(Subject)))) # All are 120, as they should be

write.csv(output_df, "Trial_Item_Information_SPR.csv", row.names = F)
