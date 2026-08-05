## Script for initial metadata cleaning

## Libraries
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(forcats)
library(purrr)
library(tidyr)

# Resolving conflicts
conflicts_prefer(dplyr::select)
conflicts_prefer(readr::cols)
conflicts_prefer(readr::col_character)
conflicts_prefer(dplyr::filter)

## Reading in and merging metadata --------------------------------------------
setwd("~/project/metadata")
metadata <- bind_rows(
  # Main metadata
  read_csv("metadata_updated.csv",
    col_types = cols(.default = col_character()),
    na = c("")
  ),
  # Additional batch metadata (21_May_2026)
  read_csv("metadata_additional96.csv",
    col_types = cols(.default = col_character()),
    na = c("")
  )
)

# Checking reasonable merging
dim(metadata)
names(metadata)

## Column names cleaning
names(metadata) <- names(metadata) %>%
  tolower() %>%
  trimws() %>%
  gsub("[[:space:]]+", "_", .) %>%
  gsub("[^a-z0-9_]", "", .) %>%
  gsub("_+", "_", .) %>%
  gsub("^_|_$", "", .)

## Checking for unique column names
any(duplicated(names(metadata)))
names(metadata)[duplicated(names(metadata))]

## Subsetting to potentially relevant columns
cols_keep <- c(
  "activation_code", "id", "created_at",
  "completed_at", "sex", "name",
  "dob", "dob_guess", "breed",
  "breed_guess", "weight", "neutered",
  "active", "body_condition", "diet",
  "food_brand", "allergies", "supplements",
  "stool", "symptoms", "conditions",
  "medication", "vaccination", "worming",
  "antibiotics", "house", "other_animals",
  "sleep", "location", "dog_type",
  "food_brand_pm_dry", "food_brand_pm_wet", "food_brand_pm_extras1",
  "food_brand_pm_extras2", "food_brand_pm_extras3"
)
metadata <- metadata[, cols_keep, drop = FALSE]

# Checking all columns had been kept
setdiff(cols_keep, names(metadata))

## Removing empty metadata rows ------------------------------------------------
# All cells containing only the first four technical columns
sum(rowSums(!is.na(metadata)) == 4)
metadata <- metadata[rowSums(!is.na(metadata)) != 4, , drop = FALSE]

## Verifying ID columns --------------------------------------------------------
# Removing white spaces
metadata$activation_code <- trimws(metadata$activation_code)
metadata$id <- trimws(metadata$id)
# Replacing empty strings with NA
metadata$activation_code[metadata$activation_code == ""] <- NA_character_
metadata$id[metadata$id == ""] <- NA_character_
# Checking for NA and duplication
sum(is.na(metadata$activation_code))
sum(duplicated(metadata$activation_code))
sum(is.na(metadata$id))
sum(duplicated(metadata$id))

## Adding batch as a factor ----------------------------------------------------
batch_map <- read_csv("batch.csv",
  col_types = cols(.default = col_character())
)
metadata <- metadata %>%
  left_join(batch_map, by = c("activation_code" = "activation_code"))
metadata$batch <- gsub("/", "-", metadata$batch)
metadata$batch <- factor(metadata$batch)

## Date columns (completed_at and created_at) ----------------------------------
# Extracting date only (removing time) and converting to date type
metadata$created_at <- as.Date(substr(trimws(metadata$created_at), 1, 10))
metadata$completed_at <- as.Date(substr(trimws(metadata$completed_at), 1, 10))
# Checking no NA
sum(is.na(metadata$created_at))
sum(is.na(metadata$completed_at))

## Guess columns and neutering as booleans -------------------------------------
metadata$dob_guess <- as.logical(as.integer(trimws(metadata$dob_guess)))
metadata$breed_guess <- as.logical(as.integer(trimws(metadata$breed_guess)))
metadata$neutered <- factor(as.logical(as.integer(trimws(metadata$neutered))))
table(metadata$neutered)

## DOB -------------------------------------------------------------------------
# As date
metadata$dob <- as.Date(trimws(metadata$dob))
# Checking no NA
sum(is.na(metadata$dob))

## Factors ---------------------------------------------------------------------
## Sex -------------------------------------------------------------------------
# Verifying unique categories
metadata$sex <- tolower(trimws(metadata$sex))
unique(metadata$sex)
# Assigning factor
metadata$sex <- factor(metadata$sex)
table(metadata$sex)

## Breed -----------------------------------------------------------------------
## Written with ELM (GPT 5.2) help, https://elm.edina.ac.uk/elm-new
# Standardizing free text for processing
x <- tolower(trimws(metadata$breed))
x <- gsub("\\s+", " ", x)
x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
x <- gsub("\\s+", " ", trimws(x))

# Collapsing typos and variants
x <- gsub("\\bfrenchbulldog\\b|\\bfrench bull dog\\b", "french bulldog", x)
x <- gsub("\\benglish toy terrirr\\b", "english toy terrier", x)
x <- gsub("\\bstaffordshire bullterier\\b", "staffordshire bull terrier", x)
x <- gsub("\\bdaschund\\b", "dachshund", x)
x <- gsub("\\blabrodor\\b|\\blabradour retriever\\b", "labrador retriever", x)
x <- gsub("\\bcavaooo\\b|\\bcavpoo\\b", "cavapoo", x)
x <- gsub("\\bsprocker spainel\\b", "sprocker spaniel", x)
x <- gsub("\\bshitzu\\b|\\bshihtzu\\b", "shih tzu", x)
x <- gsub("\\bjackrussell\\b", "jack russell", x)
x <- gsub("\\bpikaneese\\b", "pekingese", x)
x <- gsub("\\bbichon friese\\b", "bichon frise", x)
x <- gsub("\\bamerican bull dog\\b", "american bulldog", x)
x <- gsub("\\bgerman wire haired pointer\\b", "german wirehaired pointer", x)
x <- gsub("^sprocker$", "sprocker spaniel", x)
x <- gsub("\\bgolden doodle\\b", "goldendoodle", x)
x <- gsub(
  "\\bminiature golden doodle\\b|\\bminiature goldendoodle\\b",
  "miniature goldendoodle", x
)
x <- gsub("\\byorkiex\\b|\\byorkshireterrier\\b", "yorkshire terrier", x)
x <- gsub("\\bminature dachshund\\b", "miniature dachshund", x)
x <- gsub("\\bmini smooth dachund\\b", "mini smooth dachshund", x)
x <- gsub("^terr$", "terrier", x)
x <- gsub("viszla", "vizsla", x)
x <- gsub(
  "\\bwire haired hungarian vizsla\\b", "hungarian wirehaired vizsla", x
)
x <- gsub(
  "\\bhungarian wire haired vizsla\\b", "hungarian wirehaired vizsla", x
)
x <- gsub("^viszla$|^vizsla$", "hungarian vizsla", x)
x <- gsub("\\b(sharpei|shar pei|chinese shar-pei)\\b", "shar pei", x)
x <- gsub(
  paste0(
    "\\b(american bully xl|american bully|xl bully|standard american ",
    "bully|american pocket bulldog|pocket bully)\\b"
  ),
  "american bully", x
)
x <- gsub("\\bborder collie-farm\\b", "border collie", x)
x <- gsub("\\bbritish bulldog\\b", "bulldog", x)
x <- gsub("\\benglish bulldog\\b", "bulldog", x)
x <- gsub("\\bbully lurcher\\b", "bull lurcher", x)
x <- gsub("\\bcockerpoo\\b|\\bcould cokerpoo\\b", "cockapoo", x)
x <- gsub("\\bdoberman pinscher\\b", "dobermann", x)
x <- gsub("\\bdoberman\\b", "dobermann", x)
x <- gsub("\\bminiature pincher\\b", "miniature pinscher", x)
x <- gsub("\\benglish bull terrier\\b", "bull terrier", x)
x <- gsub("\\bwest highland terrier\\b", "west highland white terrier", x)
x <- gsub("\\benglish pointer\\b", "pointer", x)
x <- gsub("\\benglish singer spaniel\\b", "english springer spaniel", x)
x <- gsub("^springer spaniel$", "english springer spaniel", x)
x <- gsub("\\benglish show cocker spaniel\\b", "cocker spaniel", x)
x <- gsub("\\bshow cocker spaniel\\b", "cocker spaniel", x)
x <- gsub("\\bworking cocker spaniel\\b", "cocker spaniel", x)
x <- gsub("\\bgerman mittelspitz\\b", "german spitz", x)
x <- gsub("^jack russell$", "jack russell terrier", x)
x <- gsub("\\bmaltese terrier\\b", "maltese", x)
x <- gsub(
  "\\bmini goldendoodle\\b|\\bminiature goldendoodle\\b",
  "miniature goldendoodle", x
)
x <- gsub(
  "\\bmini smooth dachshund\\b|\\bminiature smooth hair dachshund\\b",
  "miniature dachshund", x
)
x <- gsub(
  "\\bparson jack russell\\b|\\bparsons jack russell\\b",
  "parson russell terrier", x
)
x <- gsub("^patterdale$", "patterdale terrier", x)
x <- gsub(
  "\\bminiature australian labdradoodle\\b",
  "australian labradoodle", x
)
x <- gsub("\\bolde english bulldoge\\b", "olde english bulldog", x)
x <- gsub(
  "\\bpetit bassett griffen vendeen\\b",
  "petit basset griffon vendeen", x
)
x <- gsub("\\bpetite brabancon griffon\\b", "petit brabancon griffon", x)
x <- gsub("\\bwire-haired dachshund\\b", "dachshund", x)
x <- gsub("\\bblack labrador\\b", "labrador retriever", x)
x <- gsub("\\bchocolate labrador\\b", "labrador retriever", x)
x <- gsub("^labrador$", "labrador retriever", x)
x <- gsub("\\bgsd\\b", "german shepherd", x)
x <- gsub("\\b(staffy|staffie)\\b", "staffordshire bull terrier", x)
x <- gsub("\\bpetit brabancon griffon\\b", "griffon bruxellois", x)

# Unrecognized breeds to mixed breed (adding "mixed" for later pattern matching)
# According to the Royal Kennel Club:
# https://www.royalkennelclub.com/search/breeds-a-to-z/
x <- gsub(
  "\\balapaha blueblood bulldog\\b",
  "mixed alapaha blue blood bulldog", x
)
x <- gsub("\\bamerican bully\\b", "mixed american bully", x)
x <- gsub("\\baustralian bulldog\\b", "mixed australian bulldog", x)
x <- gsub("\\baustralian labradoodle\\b", "mixed australian labradoodle", x)
x <- gsub("\\bbeaglier\\b", "mixed beaglier", x)
x <- gsub("\\bborder beagle\\b", "mixed border beagle", x)
x <- gsub("\\bboxador\\b", "mixed boxador", x)
x <- gsub("\\bbull lurcher\\b", "mixed bull lurcher", x)
x <- gsub("\\bcavachon\\b", "mixed cavachon", x)
x <- gsub("\\bcavapoo\\b", "mixed cavapoo", x)
x <- gsub("\\bcavapoo f1bb\\b", "mixed cavapoo", x)
x <- gsub("\\bcavapoochon\\b", "mixed cavapoochon", x)
x <- gsub("\\bchichon\\b", "mixed chichon", x)
x <- gsub("\\bchug\\b", "mixed chug", x)
x <- gsub("\\bcockapoo\\b", "mixed cockapoo", x)
x <- gsub("\\bcockapoochon\\b", "mixed cockapoochon", x)
x <- gsub("\\bcotonpoo\\b", "mixed cotonpoo", x)
x <- gsub("\\bdoxiepoo\\b", "mixed doxiepoo", x)
x <- gsub("\\bfrug\\b", "mixed frug", x)
x <- gsub("\\bgerman shepherd malinois\\b", "mixed german shepherd malinois", x)
x <- gsub("\\bgiant schnoodle\\b", "mixed giant schnoodle", x)
x <- gsub("\\bgoldador\\b", "mixed goldador", x)
x <- gsub("\\bgoldendoodle\\b", "mixed goldendoodle", x)
x <- gsub("\\bhong kong village dog\\b", "mixed hong kong village dog", x)
x <- gsub("\\bhuntaway\\b", "mixed huntaway", x)
x <- gsub("\\blabradoodle\\b", "mixed labradoodle", x)
x <- gsub("\\blurcher\\b", "mixed lurcher", x)
x <- gsub("\\bmalshi\\b", "mixed malshi", x)
x <- gsub("\\bmaltipoo\\b", "mixed maltipoo", x)
x <- gsub("\\bminiature cockapoo\\b", "mixed miniature cockapoo", x)
x <- gsub("\\bminiature goldendoodle\\b", "mixed miniature goldendoodle", x)
x <- gsub("\\bminiature labradoodle\\b", "mixed miniature labradoodle", x)
x <- gsub("\\bold tyme bulldog\\b", "mixed old tyme bulldog", x)
x <- gsub(
  "\\bolde english bulldog\\b",
  "mixed olde english bulldog", x
)
x <- gsub("\\bpatterdale terrier\\b", "mixed patterdale terrier", x)
x <- gsub("\\bpomchi\\b", "mixed pomchi", x)
x <- gsub("\\bpomsky\\b", "mixed pomsky", x)
x <- gsub("\\bpoochon\\b", "mixed poochon", x)
x <- gsub("\\bprague ratter\\b", "mixed prague ratter", x)
x <- gsub("\\bpugalier\\b", "mixed pugalier", x)
x <- gsub("\\bpugshire\\b", "mixed pugshire", x)
x <- gsub("\\bschnoodle\\b", "mixed schnoodle", x)
x <- gsub("\\bshih-poo\\b", "mixed shih-poo", x)
x <- gsub("\\bspringerdor\\b", "mixed springerdor", x)
x <- gsub("\\bsprocker spaniel\\b", "mixed sprocker spaniel", x)
x <- gsub("\\bsprollie\\b", "mixed sprollie", x)
x <- gsub("\\bsproodle\\b", "mixed sproodle", x)
x <- gsub("\\btoy cavapoo\\b", "mixed toy cavapoo", x)
x <- gsub("\\btoy cockapoo\\b", "mixed toy cockapoo", x)
x <- gsub("\\bunkown\\b", "mixed", x)
x <- gsub("\\butonagan\\b", "mixed utonagan", x)
x <- gsub("\\bweechon\\b", "mixed weechon", x)
x <- gsub("\\bwestiepoo\\b", "mixed westiepoo", x)
x <- gsub("\\bjorkie\\b", "mixed jorkie", x)
x <- gsub("\\bswedish farm dog\\b", "mixed swedish farm dog", x)
x <- gsub("\\balaskan klee kai\\b", "mixed alaskan klee kai", x)
x <- gsub("\\bamerican bulldog\\b", "mixed american bulldog", x)
x <- gsub(
  "\\brussian tsvetnaya bolonka\\b",
  "mixed russian tsvetnaya bolonka", x
)

# Special cases
x <- gsub(
  "\\bthird husky crossed with several other breeds\\b", "mixed husky", x
)
x <- gsub(
  "\\bfrench bulldog \\(possibly with some boston terrier\\)\\b",
  "mixed french bulldog", x
)

# Base text with parentheses removed
base <- trimws(gsub("\\([^)]*\\)", "", x))
base <- gsub("\\s+", " ", base)

# Finding mixed entries
is_mixed <- grepl(
  "\\b(mixed|mix|cross|crossbreed|unknown|rescue|mongrel)\\b|\\bx\\b|/|&|,", x
) | metadata$breed_guess
is_mixed[is.na(is_mixed)] <- FALSE

# Clean labels
breed_clean <- base
breed_clean[is_mixed] <- "mixed"

# Lumping together categories under 20 occurrences
breed_clean <- fct_lump_min(
  breed_clean,
  min = 20,
  other_level = "other_pure"
)

# Clean column
metadata$breed_clean <- breed_clean

# Assigning factor
metadata$breed_clean <- factor(metadata$breed_clean)

## Diet ------------------------------------------------------------------------
# Checking unique categories
metadata$diet <- tolower(trimws(metadata$diet))
unique(metadata$diet)
table(metadata$diet)

# Collapsing sparse categories
metadata$diet[metadata$diet
              %in%
                c("pouches", "canned")] <- "wet"
metadata$diet[metadata$diet
              %in%
                c("raw_complete", "raw_meat", "raw_fish")] <- "raw"

# Excluding vegan/vegetarian
metadata$diet[metadata$diet
              %in%
                "vegan_vegetarian"] <- NA_character_

# Assigning factor and reference
metadata$diet <- factor(metadata$diet)
metadata$diet <- relevel(metadata$diet, ref = "kibble")

## Food brand ------------------------------------------------------------------
# Exploratory purposes, excluded later - possible collinearity with diet
# Checking unique categories
unique(metadata$food_brand)
# Standardizing categories
fb <- tolower(trimws(as.character(metadata$food_brand)))
fb <- gsub("&", "and", fb)
fb <- gsub("[[:space:]]+", "_", fb)
fb <- gsub("[^a-z0-9_]+", "_", fb)
fb <- gsub("_+", "_", fb)
fb <- gsub("^_|_$", "", fb)
fb[fb == "another"] <- "other"
metadata$food_brand_clean <- fb
table(metadata$food_brand_clean)

# Assigning factor
metadata$food_brand_clean <- factor(metadata$food_brand_clean)

## Active ----------------------------------------------------------------------
# Checking unique categories
metadata$active <- tolower(trimws(metadata$active))
unique(metadata$active)
table(metadata$active)
# Assigning factor
metadata$active <- factor(metadata$active)

## Body condition --------------------------------------------------------------
# Checking unique categories
metadata$body_condition <- tolower(trimws(metadata$body_condition))
unique(metadata$body_condition)

# Merging categories
metadata$body_condition[metadata$body_condition
                        %in%
                          c("normal_weight", "normalweight")] <- "normalweight"
metadata$body_condition[metadata$body_condition
                        %in%
                          c("overweight", "obese")] <- "overweight"
table(metadata$body_condition)

# Assigning factor and reference
metadata$body_condition <- factor(metadata$body_condition)
metadata$body_condition <- relevel(metadata$body_condition, ref = "overweight")

## Stool -----------------------------------------------------------------------
# Exploratory purposes, excluded later - overlap with symptoms/conditions
# Checking unique categories
metadata$stool <- tolower(trimws(metadata$stool))
unique(metadata$stool)
table(metadata$stool)
# Assigning factor
metadata$stool <- factor(metadata$stool)

## Vaccination -----------------------------------------------------------------
# Exploratory purposes, excluded later - irrelevant
# Checking unique categories
metadata$vaccination <- tolower(trimws(metadata$vaccination))
unique(metadata$vaccination)
table(metadata$vaccination)
# Assigning factor
metadata$vaccination <- factor(metadata$vaccination)

## Worming ---------------------------------------------------------------------
# Checking unique categories
metadata$worming <- tolower(trimws(metadata$worming))
unique(metadata$worming)
table(metadata$worming)

# Merging categories
metadata$worming[metadata$worming
%in%
  c(
    "within_1_3_months ",
    "within_3_months"
  )] <- "within_1_3_months"

# Assigning factor and reference
metadata$worming <- factor(metadata$worming)
metadata$worming <- relevel(metadata$worming, ref = "within_1_3_months")

## Antibiotics -----------------------------------------------------------------
# Checking unique categories
metadata$antibiotics <- tolower(trimws(metadata$antibiotics))
unique(metadata$antibiotics)
table(metadata$antibiotics)

# Merging categories
metadata$antibiotics[metadata$antibiotics
                     %in%
                       c("3-6_months", "within_6_months")] <- "3-6_months"

# Assigning factor
metadata$antibiotics <- factor(metadata$antibiotics)

## House -----------------------------------------------------------------------
# Exploratory purposes, excluded later - irrelevant
# Checking unique categories
metadata$house <- tolower(trimws(metadata$house))
unique(metadata$house)
table(metadata$house)

# Merging categories
metadata$house[metadata$house
               %in%
                 c("house_large_garden", "large_garden")] <- "large_garden"

# Assigning factor
metadata$house <- factor(metadata$house)

## Sleep -----------------------------------------------------------------------
# Exploratory purposes, excluded later - irrelevant
# Checking unique categories
metadata$sleep <- tolower(trimws(metadata$sleep))
unique(metadata$sleep)
table(metadata$sleep)

# Assigning factor
metadata$sleep <- factor(metadata$sleep)

## Location (living environment) -----------------------------------------------
# Checking unique categories
metadata$location <- tolower(trimws(metadata$location))
unique(metadata$location)
table(metadata$location)

# Assigning factor and reference
metadata$location <- factor(metadata$location)
metadata$location <- relevel(metadata$location, ref = "urban")

## Dog type --------------------------------------------------------------------
# Exploratory purposes, excluded later - severe imbalance
# Checking unique categories
metadata$dog_type <- tolower(trimws(metadata$dog_type))
unique(metadata$dog_type)
table(metadata$dog_type)

# Assigning factor
metadata$dog_type <- factor(metadata$dog_type)

## Weight as numerical ---------------------------------------------------------
# Excluded later
metadata$weight <- as.numeric(trimws(metadata$weight))

## Columns with multiple fields ------------------------------------------------
# Helper function to generate a list of categories from a comma-separated string
parse_items <- function(x) {
  x <- tolower(trimws(as.character(x)))

  # Splitting on the comma
  out <- strsplit(x, ",", fixed = TRUE)

  out <- lapply(out, function(v) {
    if (length(v) == 1 && is.na(v)) {
      return(NA_character_)
    }

    # Cleaning white spaces
    v <- trimws(v)
    # Filtering out empty strings
    v <- v[nzchar(v)]
    # Keeping only unique elements
    v <- unique(v)

    if (length(v) == 0) NA_character_ else v
  })

  out
}

# Supplements ------------------------------------------------------------------
# Cleaning
metadata <- metadata %>%
  mutate(supplements_list = map(supplements, parse_items))
unique(na.omit(unlist(metadata$supplements_list)))
table(na.omit(unlist(metadata$supplements_list)))

# Keeping only biotic supplements as potential influences
metadata <- metadata %>%
  mutate(
    has_pre = grepl("\\bprebiotic\\b", supplements),
    has_post = grepl("\\bpostbiotic\\b", supplements),
    # Factor categories
    biotics = case_when(
      has_pre & has_post ~ "both",
      has_pre ~ "prebiotic",
      has_post ~ "postbiotic",
      TRUE ~ "none"
    ),
    biotics = factor(biotics, levels = c(
      "prebiotic", "postbiotic",
      "both", "none"
    ))
  ) %>%
  select(-has_pre, -has_post)

# Factor reference
metadata$biotics <- relevel(metadata$biotics, ref = "none")

# Other animals ----------------------------------------------------------------
# Exploratory purposes, excluded later - cannot determine actual contact level
x <- tolower(trimws(as.character(metadata$other_animals)))
x[x == ""] <- NA_character_

# Merging categories
x <- gsub("\\bdogs\\b", "other_dogs", x)

# Cleaning
metadata$other_animals <- x
metadata <- metadata %>%
  mutate(other_animals_list = map(other_animals, parse_items))
unique(na.omit(unlist(metadata$other_animals_list)))
table(na.omit(unlist(metadata$other_animals_list)))

# Symptoms ---------------------------------------------------------------------
# Cleaning
metadata <- metadata %>%
  mutate(symptoms_list = map(symptoms, parse_items))
unique(na.omit(unlist(metadata$symptoms_list)))
table(na.omit(unlist(metadata$symptoms_list)))

# Grouping by symptom type
metadata <- metadata %>% mutate(
  gastro = grepl(paste0(
    "\\b(abdominal_pain|acid_reflux|anal_gland_issues|",
    "blood_in_stool|constipation|diarrhea|",
    "excessive_grass_eating_flatulence|loss_of_appetite|",
    "mucous_in_stool|soft_stool|unexplained_weight_loss|",
    "variable_stool|vomiting)\\b"
  ), symptoms),
  skin = grepl("\\bskin_itching_allergies\\b", symptoms),
  neuro = grepl("\\b(anxiety|behavioural_changes)\\b", symptoms),
  joint = grepl("\\bjoint_pain_mobility_issues\\b", symptoms),
  resp = grepl("\\bcoughing\\b", symptoms),
  metabol = grepl("\\bincreased_thirst_urination\\b", symptoms),
  gastro = if_else(gastro, true = TRUE,
    false = FALSE, missing = FALSE
  ),
  skin = if_else(skin, true = TRUE,
    false = FALSE, missing = FALSE
  ),
  neuro = if_else(neuro, true = TRUE,
    false = FALSE, missing = FALSE
  ),
  resp = if_else(resp, true = TRUE,
    false = FALSE, missing = FALSE
  ),
  metabol = if_else(metabol, true = TRUE,
    false = FALSE, missing = FALSE
  ),
)

# Individual binary symptom columns
metadata$gastro <- factor(metadata$gastro)
metadata$skin <- factor(metadata$skin)
metadata$neuro <- factor(metadata$neuro)
metadata$resp <- factor(metadata$resp)
metadata$metabol <- factor(metadata$metabol)

# Health-status column
# No symptoms, no vet-diagnosed conditions and no medication
metadata <- metadata %>%
  mutate(
    healthy = if_else(
      (is.na(symptoms) & is.na(conditions) & is.na(medication)),
      true = TRUE,
      false = FALSE
    )
  )
metadata$healthy <- factor(metadata$healthy)

# Conditions -------------------------------------------------------------------
# Exploratory purposes, excluded later - cannot determine dysbiosis status
metadata$conditions_list <- parse_items(metadata$conditions)
unique(na.omit(unlist(metadata$conditions_list)))
table(na.omit(unlist(metadata$conditions_list)))

## Exploratory inspection of the variables -------------------------------------
# Weight -----------------------------------------------------------------------
weight_hist <- ggplot(metadata, aes(x = weight)) +
  geom_histogram(fill = "turquoise") +
  ggtitle("Weight Distribution") +
  xlab("Weight [Kg]") +
  ylab("Count") +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12),
    axis.text.x = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
  )

# Age --------------------------------------------------------------------------
# Age in years
# Categories according to:
# www.aaha.org/resources/life-stage-canine-2019/canine-life-stage-definitions/
# And: https://doi.org/10.1111/1462-2920.14540
metadata <- metadata %>%
  mutate(
    age_years = time_length(interval(dob, completed_at), "years"),
    # Categories according to cut-offs in years
    age_categorical = case_when(
      is.na(age_years) ~ NA_character_,
      age_years < 0 ~ NA_character_,
      age_years < 0.75 ~ "puppy",
      age_years < 2 ~ "young_adult",
      age_years < 8 ~ "mature_adult",
      TRUE ~ "senior"
    ),
    age_categorical = factor(age_categorical)
  )

# Histogram
age_hist <- metadata %>%
  # Keeping only positive ages
  filter(!is.na(age_years), age_years > 0) %>%
  ggplot(aes(x = age_years)) +
  geom_histogram(fill = "steelblue2") +
  scale_x_continuous(
    breaks = seq(0, 25, by = 1)
  ) +
  ggtitle("Age Distribution") +
  xlab("Age [years]") +
  ylab("Count") +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12),
    axis.text.x = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
  )

# Supplements ------------------------------------------------------------------
supp_counts <- metadata %>%
  mutate(
    supplements_list = map(supplements_list, \(x) unlist(x, use.names = FALSE))
  ) %>%
  unnest_longer(supplements_list, values_to = "supplement") %>%
  mutate(
    supplement = fct_explicit_na(supplement, na_level = "no_supplements")
  ) %>%
  count(supplement, name = "n") %>%
  mutate(supplement = fct_reorder(supplement, n))

# Barplot
supp_barplot <- ggplot(supp_counts, aes(x = supplement, y = n)) +
  geom_col(fill = "seagreen2") +
  ggtitle("Supplement Distribution") +
  xlab("Supplement Type") +
  ylab("Number of Samples") +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12),
    axis.text.x = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
  )

# Biotics stats ----------------------------------------------------------------
# Sums
metadata %>%
  summarize(
    n_either = sum(map_lgl(supplements_list, function(x) {
      any(
        x
        %in%
          c(
            "prebiotic",
            "postbiotic"
          ),
        na.rm = TRUE
      )
    })),
    n_both = sum(map_lgl(supplements_list, function(x) {
      all(c(
        "prebiotic",
        "postbiotic"
      )
      %in%
        x)
    }))
  )

# And percentages
metadata %>%
  summarize(
    n_either = sum(map_lgl(supplements_list, function(x) {
      any(
        x
        %in%
          c(
            "prebiotic",
            "postbiotic"
          ),
        na.rm = TRUE
      )
    })) *
      100 / nrow(metadata),
    n_both = sum(map_lgl(supplements_list, function(x) {
      all(c(
        "prebiotic",
        "postbiotic"
      )
      %in%
        x)
    })) *
      100 / nrow(metadata)
  )

# Symptoms ---------------------------------------------------------------------
sym_counts <- metadata %>%
  mutate(symptoms_list = map(
    symptoms_list,
    \(x) unlist(x, use.names = FALSE)
  )) %>%
  unnest_longer(symptoms_list, values_to = "symptom") %>%
  mutate(
    symptom = factor(symptom),
    symptom = fct_explicit_na(symptom, na_level = "no_symptoms_reported")
  ) %>%
  count(symptom, name = "n") %>%
  mutate(symptom = fct_reorder(symptom, n))

# Percentage of no symptoms
n_no_symptoms <- sym_counts %>%
  filter(as.character(symptom) == "no_symptoms_reported") %>%
  pull(n)

100 * n_no_symptoms / nrow(metadata)

# Barplot
sym_barplot <- ggplot(sym_counts, aes(y = symptom, x = n)) +
  geom_col(fill = "deepskyblue") +
  ggtitle("Symptom Distribution") +
  ylab("Symptom Type") +
  xlab("Number of Samples") +
  theme(
    axis.title.y = element_text(face = "bold", size = 12),
    axis.text.x = element_text(face = "bold", size = 10),
    axis.text.y = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
  )

# Other animals ----------------------------------------------------------------
# How many samples are exposed to more than one animal type?
metadata %>%
  summarize(
    n = sum(map_int(other_animals_list, \(x) length(unique(na.omit(x)))) > 1)
  ) %>%
  pull(n) * 100 / nrow(metadata)

# Individual categories count (no multiple fields)
animals_counts <- metadata %>%
  mutate(other_animals_list = map(
    other_animals_list,
    \(x) unlist(x, use.names = FALSE)
  )) %>%
  unnest_longer(other_animals_list, values_to = "animals") %>%
  mutate(
    animals = fct_explicit_na(animals, na_level = "no_exposure")
  ) %>%
  count(animals, name = "n") %>%
  mutate(animals = fct_reorder(animals, n))

# Barplot
animals_barplot <- ggplot(animals_counts, aes(x = animals, y = n)) +
  geom_col(fill = "aquamarine") +
  ggtitle("Exposure to Other Animals") +
  xlab("Animal Type") +
  ylab("Number of Samples") +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12),
    axis.text.x = element_text(size = 12),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
  )

## Saving as an RDS object -----------------------------------------------------
## Keeping only relevant columns
cols_final <- c(
  "activation_code", "name", "dob", "sex",
  "breed_clean", "weight", "neutered",
  "active", "body_condition", "diet",
  "food_brand_clean", "biotics", "stool",
  "gastro", "skin", "neuro",
  "joint", "resp", "metabol",
  "healthy", "vaccination", "worming",
  "antibiotics", "house", "location",
  "age_years", "age_categorical", "batch"
)
metadata_clean <- metadata[, cols_final, drop = FALSE]
saveRDS(metadata_clean, "metadata_clean.rds")
