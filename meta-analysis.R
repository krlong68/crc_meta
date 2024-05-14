library(curatedMetagenomicData)
library(OmicsMLRepoR)
library(tidyverse)

#cMD_curated_meta <- read.csv("/home/kaelyn/Desktop/Work/OmicsMLRepoData/inst/extdata/cMD_curated_metadata_all.csv")
cMD_curated_meta <- getMetadata("cMD")
crc_meta <- cMD_curated_meta %>%
    filter(grepl("colorectal cancer", target_condition))
#searchMetadata("colorectal cancer", cMD_curated_meta, "cMD", delim = ";")
uncurated_metadata <- sampleMetadata

new_studies <- unique(crc_meta$study_name)
new_studies <- new_studies[new_studies != "WirbelJ_2018"]

original_data <- curatedMetagenomicData("WirbelJ_2018", dryrun = FALSE)
original_study_metadata <- uncurated_metadata %>%
    filter(study_name == "WirbelJ_2018")
curated_study_metadata <- cMD_curated_meta %>%
    filter(study_name == "WirbelJ_2018")

# Get meta.all from prepare_data.R
use_ids <- intersect(meta.crc$Sample_ID, uncurated_metadata$sample_id)

native_meta <- meta.all %>% filter(Sample_ID %in% use_ids)
og_cmd_meta <- uncurated_metadata %>% filter(sample_id %in% use_ids)
c_cmd_meta <- cMD_curated_meta %>% filter(sample_id %in% use_ids)
