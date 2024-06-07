library(curatedMetagenomicData)
library(tidyverse)

# Personal wd setup
setwd("/home/kaelyn/Desktop/Work/crc_meta/src")
options(timeout = 1000)

# Step 1. Native Run
# Run necessary portions of prepare_data.R to retrieve relative abundances and
# metadata for CRC studies.
# Scripts: prepare_data.R; marker_analysis.R (tag = "species");
# figure_marker_heatmap.R (tag = "species")

# Step 2. Collect potential cMD studies for meta-analysis
#native_studies <- c("ZellerG_2014",
#                    "FengQ_2015",
#                    "YuJ_2015",
#                    "VogtmannE_2016")
studies <- c("GuptaA_2019",
             "HanniganGD_2017",
             "ThomasAM_2018a",
             "ThomasAM_2018b",
             "ThomasAM_2019_c",
             "YachidaS_2019")
pattern <- paste(paste0(studies, ".relative_abundance"), collapse = "|")
curatedMetagenomicData(pattern, dryrun = TRUE)
collected_studies <- curatedMetagenomicData(pattern,
                                            rownames = "short",
                                            dryrun = FALSE)
all_assays <- lapply(collected_studies, function(x) as.data.frame(t(assays(x)$relative_abundance)))
comb_assays <- t(bind_rows(all_assays))
comb_assays[is.na(comb_assays)] <- 0

# Step 3. Collect curated metadata for all samples
samples <- colnames(comb_assays)
cMD_curated_meta <- read.csv("/home/kaelyn/Desktop/Work/redo/OmicsMLRepoData/inst/extdata/cMD_curated_metadata_all.csv")
s_meta <- cMD_curated_meta %>%
    filter(sample_id %in% samples)

# Step 4. Format data/metadata for run
f_meta <- s_meta %>%
    select(Study = study_name,
           Sample_ID = sample_id,
           Age = age_years,
           Gender = sex,
           BMI = bmi,
           Group = control,
           AJCC_stage = tumor_staging_ajcc) %>%
    mutate(Gender = ifelse(Gender == "Male", "M", "F")) %>%
    mutate(Group = ifelse(Group == "Case", "CRC", "CTR"))

study_colors <- list("#FF9774", "#F2CC30", "#74B347",
                     "#2FBFBF", "#1178D8", "#8265CC")
names(study_colors) <- studies

# Step 5. Run
# marker_analysis.R
feat.all <- comb_assays
meta <- f_meta

# figure_marker_heatmap.R
ref.studies <- studies
study.colors <- study_colors

# cluster_species.R
meta <- f_meta
feat <- comb_assays
study.colors <- study_colors

# train_models.R
meta <- f_meta
feat.all <- comb_assays
ref.studies <- studies

# figure_performance.R
meta <- f_meta
ref.studies <- studies
########################################

#cMD_curated_meta <- read.csv("/home/kaelyn/Desktop/Work/OmicsMLRepoData/inst/extdata/cMD_curated_metadata_all.csv")
cMD_curated_meta <- getMetadata("cMD")
crc_meta <- cMD_curated_meta %>%
    filter(grepl("colorectal cancer", target_condition))
#searchMetadata("colorectal cancer", cMD_curated_meta, "cMD", delim = ";")
uncurated_metadata <- sampleMetadata

new_studies <- unique(crc_meta$study_name)
new_studies <- new_studies[new_studies != "WirbelJ_2018"]

original_data <- curatedMetagenomicData("ThomasAM_2018", dryrun = TRUE)
original_data <- curatedMetagenomicData("WirbelJ_2018.relative_abundance", dryrun = FALSE, rownames = "short")
original_study_metadata <- uncurated_metadata %>%
    filter(study_name == "WirbelJ_2018")
curated_study_metadata <- cMD_curated_meta %>%
    filter(study_name == "WirbelJ_2018")

# AT/CN cMD vs. native IDs
AT_cMD <- cMD_curated_meta %>%
    filter(pmid == 25758642) %>%
    pull(sample_id)
CN_cMD <- cMD_curated_meta %>%
    filter(pmid == 26408641) %>%
    pull(sample_id)
AT_native <- meta.all %>%
    filter(Study == "AT-CRC") %>%
    pull(External_ID)
CN_native <- meta.all %>%
    filter(Study == "CN-CRC") %>%
    pull(External_ID)

# Get meta.all from prepare_data.R
use_ids <- intersect(meta.crc$Sample_ID, uncurated_metadata$sample_id)

native_meta <- meta.all %>% filter(Sample_ID %in% use_ids)
og_cmd_meta <- uncurated_metadata %>% filter(sample_id %in% use_ids)
c_cmd_meta <- cMD_curated_meta %>% filter(sample_id %in% use_ids)
