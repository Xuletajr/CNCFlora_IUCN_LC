# filtrar o arquivo do inpa

# Ler os pacotes
library(readxl)
library(dplyr)

# Ler a planilha de dados proveniente do speciesLink
tabela_inpa_splink <- read_excel(path = "./data/planilha_geral_splink_inpa.xlsx", sheet = 1)

# Ler a planilha de espécies do recorte após ter sido gerada pelo script "02 flora"
head(unique(tabela_inpa_splink$scientificname))
inpa_filtered <- tabela_inpa_splink %>% filter(tabela_inpa_splink$scientificname %in% especies)

# Exportando uma planilha com os dados do speciesLink filtrados pelas espécies de interesse
write.csv(inpa_filtered, "./output/inpa_filtrado.csv")
