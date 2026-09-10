# Pipeline reprodutível de estimação de SOH

Este pacote reproduz o pipeline interno do `SOH_ARTIGOV2` até as incertezas U1, U2, U3 (conformal normalizado) e U3-Mondrian, em duas variantes:

1. `01_SOH_V2_COM_MILEAGE.ipynb`: 20 features físicas selecionadas + `mileage` como entrada dos modelos (21 entradas).
2. `02_SOH_V2_SEM_MILEAGE.ipynb`: as mesmas 20 features físicas, sem `mileage` como entrada dos modelos. `mileage` permanece somente como identificador/metadado e como restrição legada de vizinhança do SMOTER.

Os notebooks terminam deliberadamente após a auditoria das incertezas. Não incluem os experimentos posteriores com os Datasets 1 e 3.

## Conteúdo

- `data/data_real_EV_charge.pkl`: entrada compartilhada, com 12.128 eventos de recarga e 83 carros.
- `data/data_real_EV_charge.manifest.json`: esquema, proveniência técnica e SHA-256 da entrada.
- `cache/`: criado/preenchido durante a execução; começa vazio.
- `outputs/`: recebe os notebooks executados.
- `outputs_reference/`: métricas previamente obtidas para conferência.
- `environment.yml`: ambiente Conda portátil, sem builds fixados.
- `conda-explicit-win-64.txt`: especificação exata do ambiente original para Windows 64 bits.
- `requirements-minimal.txt`: dependências mínimas fixadas usadas pelos notebooks.
- `requirements-pip-lock.txt`: registro integral dos pacotes visíveis ao `pip` no computador de origem; serve para auditoria, não é a opção recomendada de instalação.
- `system-info.json`: plataforma na qual o pacote foi preparado.
- `SHA256SUMS.json`: hashes dos arquivos imutáveis do pacote.
- `verify_package.ps1`: verifica integridade antes da execução.
- `run_all.ps1`: executa as variantes em ordem.

## Requisitos recomendados

- Windows 10/11 de 64 bits;
- Miniconda ou Anaconda;
- pelo menos 16 GB de RAM; 32 GB são recomendados;
- pelo menos 10 GB livres para entrada, caches e notebooks executados;
- CPU multicore. GPU não é obrigatória para os modelos ExtraTrees utilizados;
- tempo estimado de 1 a 3 horas para os dois notebooks partindo de `cache/` vazio, dependendo da CPU, memória e armazenamento.

## Segurança do arquivo PKL

Arquivos Pickle podem executar código durante o carregamento. Use somente a cópia recebida de uma fonte acadêmica confiável e confirme o SHA-256 antes de executar.

## Clonagem do repositório

O dataset é versionado com Git LFS. Instale o Git LFS antes da clonagem e materialize o arquivo de dados:

```powershell
git lfs install
git clone https://github.com/guimatiolli/ev-battery-soh-conformal.git
cd ev-battery-soh-conformal
git lfs pull
```

Depois do `git lfs pull`, `data/data_real_EV_charge.pkl` deve ter aproximadamente 1,47 GB. Um arquivo de poucos bytes indica que somente o ponteiro LFS foi obtido e o pipeline não deve ser iniciado.

## Criação do ambiente

Opção recomendada, mais portátil:

```powershell
conda env create -n soh_gpu -f environment.yml
```

Se o ambiente já existir:

```powershell
conda env update -n soh_gpu -f environment.yml --prune
```

`conda-explicit-win-64.txt` registra exatamente os builds do computador de origem, mas é menos portátil. Ele deve ser usado somente em Windows 64 bits e apenas se a criação pelo YAML não reproduzir as dependências.

## Verificação antes de executar

Abra o PowerShell nesta pasta e rode:

```powershell
powershell -ExecutionPolicy Bypass -File .\verify_package.ps1
```

O resultado esperado é `PACKAGE_OK`.

## Execução automática

```powershell
powershell -ExecutionPolicy Bypass -File .\run_all.ps1 -EnvironmentName soh_gpu
```

Ordem utilizada:

1. variante com `mileage`;
2. variante sem `mileage`.

Os notebooks executados serão escritos em:

- `outputs/01_SOH_V2_COM_MILEAGE_EXECUTADO.ipynb`;
- `outputs/02_SOH_V2_SEM_MILEAGE_EXECUTADO.ipynb`.

Os notebooks originais não são sobrescritos. Os caches comuns de extração, targets, limpeza, folds e seleção são reutilizados pela segunda variante. Os caches de modelagem sem `mileage` possuem sufixo `nomileage` e não sobrescrevem os resultados com `mileage`.

## Execução manual

Também é possível abrir cada notebook no VS Code ou Jupyter, selecionar o kernel do ambiente `soh_gpu` e usar `Run All`, respeitando a ordem acima.

## Checkpoints esperados

- 12.128 eventos únicos;
- 83 carros;
- zero IDs duplicados;
- 259 colunas no conjunto base antes dos targets;
- 283 colunas no conjunto estendido antes dos targets;
- 272 colunas no conjunto legado com targets;
- 296 colunas no conjunto estendido com targets;
- 11.565 eventos na população `Clean 1` usada pela avaliação principal;
- 403 eventos `Clean 1` com `SOH <= 0,94`.

## Métricas principais de referência

| Variante | Modelo | RMSE global | RMSE em SOH <= 0,94 |
|---|---|---:|---:|
| Com mileage | Global Clean | 0,007983 | 0,016655 |
| Com mileage | Ensemble residual Clean | 0,008052 | 0,012654 |
| Sem mileage | Global Clean | 0,010340 | 0,023967 |
| Sem mileage | Ensemble residual Clean | 0,010506 | 0,018318 |

Diferenças muito pequenas podem ocorrer entre plataformas ou versões de bibliotecas. Divergências relevantes nos checkpoints de eventos, colunas ou hashes devem ser tratadas como falha de reprodução.

## Resultados U3 de referência — cobertura nominal de 95%

| Variante | Modelo | Escopo | Cobertura | Largura média |
|---|---|---|---:|---:|
| Com mileage | Global | Todos | 94,82% | 0,02819 |
| Com mileage | Global | SOH <= 0,94 | 81,14% | 0,03918 |
| Com mileage | Ensemble residual | Todos | 95,10% | 0,02924 |
| Com mileage | Ensemble residual | SOH <= 0,94 | 91,32% | 0,04413 |
| Sem mileage | Global | Todos | 95,06% | 0,03747 |
| Sem mileage | Global | SOH <= 0,94 | 74,94% | 0,05400 |
| Sem mileage | Ensemble residual | Todos | 95,10% | 0,03840 |
| Sem mileage | Ensemble residual | SOH <= 0,94 | 88,34% | 0,05885 |

## Uso científico e redistribuição

Este pacote foi organizado para revisão acadêmica privada. Antes de publicar os dados em GitHub, Zenodo ou outro repositório, confirme os termos de licença e a permissão de redistribuição do dataset de origem. O Git deve armazenar o código e arquivos pequenos; o PKL de aproximadamente 1,47 GB deve ser publicado em repositório de dados apropriado, com DOI e hash.
