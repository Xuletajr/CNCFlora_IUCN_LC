# Read packages
library(readr)
library(readxl)
library(dplyr)
library(flora)

# Read flora data
flora <- read_csv("./ipt/all_flora.csv") %>% dplyr::select(-1)
head(flora)

# Read original data----
treespp <- read_excel("./data/LeastConcern_BrazilEndemics_original.xlsx", sheet = 1) %>%
    rename(scientificName = ScientificName) %>%
    mutate(nombre = purrr::map(scientificName, ~remove.authors(.)) %>%
               simplify2array())

treespp2 <- treespp %>%
    dplyr::select(Family, scientificName, nombre) %>%
    rename(original_name = scientificName) %>%
    left_join(flora) %>%
    dplyr::select(
           Family,
           original_name,
           scientificName,
           nombre,
           taxonID,
           acceptedNameUsageID,
           acceptedNameUsage,
           parentNameUsage,
           family,
           taxonomicStatus,
           nomenclaturalStatus,
           taxonRank,
           vernacular_names,
           nombre)

treespp2[645,] %>% View()

# Exclui os nomes mal aplicados e não validamente publicados 
treespp2_nodupl <- treespp2 %>%
    filter(!nomenclaturalStatus %in% c("NOME_MAL_APLICADO", "NOME_NAO_VALIDAMENTE_PUBLICADO"))

treespp2_nodupl %>% count(is.na(acceptedNameUsage), taxonomicStatus, nomenclaturalStatus)

# Se o nome da sp está correto: scientificName - se não é aceito (deve incluir sinônimos)
treespp3 <- treespp2_nodupl %>%
    mutate(final_name = ifelse(
# TaxonomicStatus == "NOME_ACEITO",
    is.na(acceptedNameUsage),
    scientificName, acceptedNameUsage)) %>%
    mutate(final_ID = ifelse(
    is.na(acceptedNameUsage),
    taxonID, acceptedNameUsageID)) %>%
# Si no lo encuentra
    mutate(final_name = ifelse(is.na(taxonID), original_name, final_name)) %>%
    mutate(final_family = if_else(!is.na(family), family, Family)) %>%
# New column notes
    mutate(notes = if_else(is.na(taxonID),
                           "not found", "LFB")) %>%
# New column syn
    mutate(tax_notes = if_else(
    taxonomicStatus == "NOME_ACEITO" & nomenclaturalStatus == "NOME_CORRETO", "name ok", "")) %>%
    mutate(tax_notes = if_else(taxonomicStatus == "SINONIMO", "synonym", tax_notes)) %>%
    mutate(tax_notes = if_else(is.na(taxonomicStatus), nomenclaturalStatus, tax_notes)) %>%

    mutate(notes_fam = if_else(final_family != Family, "family changed", "")) %>%

    rename(
        original_family = Family,
        name_in_Flora = scientificName,
        original_ID = taxonID,
        scientificName = final_name,
        taxonID = final_ID) %>%
        dplyr::select(original_family, original_name, name_in_Flora,original_ID,
                  final_family, scientificName, taxonID,
                  vernacular_names,
                  notes, tax_notes, notes_fam
                  )

# Remove o nome dos autores do nome da espécie - essa colunaserá usada para unir as tabelas
treespp3 <- treespp3 %>%
    mutate(nombre = purrr::map(scientificName, ~remove.authors(.)) %>%
                                    simplify2array())

View(treespp3[642,])

# Exporta a planilha de espécies com informações do Flora do Brasil-IPT
write.csv(treespp3, "./results/names_flora1.csv")

# Checar se todos os todos acceptednameusage são NAs
treespp4 <- treespp3 %>%
    left_join(flora) %>% select(acceptedNameUsage) %>% count(is.na(acceptedNameUsage))
treespp4 <- treespp3 %>%
    left_join(flora) %>%
dplyr::select(1:12, -c(13:37), 38:40, -c(41:46),47:49, -c(50:55))
names(treespp4)

# Exportar a planilha de espécies com informações do Flora do Brasil-IPT
write.csv(treespp4, "./results/names_flora.csv")
treesp4$nombre
fl <- read.csv("./results/names_flora.csv")
names(fl)
unique(fl$habitat)
