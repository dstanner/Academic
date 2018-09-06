library(dplyr)
library(tidyr)

# Load full datasets exported from matlab
N4_data <- read.csv("../Datafiles/N4_trial_amplitudes.csv")
P6_data <- read.csv("../Datafiles/P6_trial_amplitudes.csv")


# Due to an RA error, ppt 138 had a second task recorded with their experiment
# EEG recording, which resulted in 5 extra events from the second task getting 
# included with the bin labels for this task; this was fixed elsewise in the standard
# ERP analysis. Here we exclude the last five observations from that ppt's data
p138_N4 <- N4_data[N4_data$Subject == 138, ]
N4_data <- N4_data[N4_data$Subject != 138, ]
p138_N4 <- p138_N4[-c(121:125),]
N4_data <- rbind(N4_data, p138_N4)
rm(p138_N4)

p138_P6 <- P6_data[P6_data$Subject == 138, ]
P6_data <- P6_data[P6_data$Subject != 138, ]
p138_P6 <- p138_P6[-c(121:125), ]
P6_data <- rbind(P6_data, p138_P6)
rm(p138_P6)


# Subset to non-rejected trials
N4_data <- subset(N4_data, Rejected == 0)
P6_data <- subset(P6_data, Rejected == 0)


# Subset to the electrodes we want
keep_cols <- unlist(strsplit("C3 Cz C4 CP1 CP2 P3 Pz P4 Index Epoch Bin Subject", split = " "))

N4_data <- N4_data[keep_cols]
P6_data <- P6_data[keep_cols]
rm(keep_cols)


# Make columns for fixed factors
N4_data$Grammaticality <- ifelse(N4_data$Bin %in% c(1, 3), "Gram", "Ungram")
P6_data$Grammaticality <- ifelse(P6_data$Bin %in% c(1, 3), "Gram", "Ungram")

N4_data$VerbType <- ifelse(N4_data$Bin %in% c(1, 2), "Aux", "Lex")
P6_data$VerbType <- ifelse(P6_data$Bin %in% c(1, 2), "Aux", "Lex")

# Get item numbers from output of Item/event processing scripts
item_info_RSVP <- read.csv("../Datafiles/Trial_Item_information_RSVP.csv")
item_info_SPR <- read.csv("../Datafiles/Trial_Item_Information_SPR.csv")
items_df <- rbind(item_info_RSVP, item_info_SPR)
N4_data <- left_join(N4_data, select(items_df, -c(PrecritCode, Event_code)), by = c("Subject", "Index", "Bin"))
P6_data <- left_join(P6_data, select(items_df, -c(PrecritCode, Event_code)), by = c("Subject", "Index", "Bin"))
rm(item_info_RSVP,item_info_SPR,items_df)


# Convert to long
N4_data <- gather(N4_data, "Elec", "Amplitude", -c(9:15))
P6_data <- gather(P6_data, "Elec", "Amplitude", -c(9:15))


# Collapse across electrodes
collapsed_N4_data <- N4_data %>%
  group_by(Subject, Grammaticality, VerbType, Item) %>%
  summarize(
    Amplitude = mean(Amplitude)
  ) %>% ungroup() %>% as.data.frame()

collapsed_P6_data <- P6_data %>%
  group_by(Subject, Grammaticality, VerbType, Item) %>%
  summarize(
    Amplitude = mean(Amplitude)
  ) %>% ungroup() %>% as.data.frame()


# Get Individual Differences Data
ID_data <- read.csv("../Datafiles/IndividualDifferences_with_scores.csv")
collapsed_N4_data <- left_join(collapsed_N4_data, ID_data, by = c("Subject" = "ParticipantID"))
collapsed_P6_data <- left_join(collapsed_P6_data, ID_data, by = c("Subject" = "ParticipantID"))
rm(ID_data)

# Scale all predictor variables
collapsed_N4_data[6:12] <- lapply(collapsed_N4_data[6:12], scale)
collapsed_P6_data[6:12] <- lapply(collapsed_P6_data[6:12], scale)


# Make categorical predictors, subjects, items, and electrode into fctors
collapsed_N4_data[1:4] <- lapply(collapsed_N4_data[1:4], as.factor)
collapsed_P6_data[1:4] <- lapply(collapsed_N4_data[1:4], as.factor)

# Get data with just the rotated components
ID_vars <- unlist(strsplit("AuthorRecognition PPVT NAART OSpanPartial LetterNumberSequencing", split = " "))
cols <- which(colnames(collapsed_N4_data) %in% ID_vars)
RC_N4_data <- collapsed_N4_data[,-cols]
RC_P6_data <- collapsed_P6_data[,-cols]
rm(cols, ID_vars, N4_data, P6_data)
