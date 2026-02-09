This repository contains the annotated dataset and scripts used for the abstract *On the Prevalence of Different Types of Lexical Semantic Changes: Preliminary Findings*, to appear in the **Proceedings of** [**EvoLang 2026**](https://sites.google.com/york.ac.uk/evolang2026/home).

## Repository Contents

- **[AnnotationGuide.pdf](AnnotationGuide.pdf)**: Annotation guidelines used during the manual annotation process.

- **[DatSemShift.csv](DatSemShift.csv)**: Full snapshot of the [**DatSemShift**](https://datsemshift.ru) database at the time of extraction (October 2025).

- **[DatSemShiftScraper.py](DatSemShiftScraper.py)**: Updated script for scraping data from the [DatSemShift database](https://datsemshift.ru).

- **[DataAnalysis.R](DataAnalysis.R)**: Script for generating the plots used in the abstract.

- **[DatasetConstruction.ipynb](DatasetConstruction.ipynb)**: Notebook that constructs the annotation datasets from **DatSemShift.csv**.

- **[FinalData.csv](FinalData.csv)**: Annotated dataset including **Semantic Change Types**, **POS tags**, **Comments**, and **Confidence rankings**.

- **[Scraper.py](Scraper.py)**: Original scraping script. This version is now outdated due to recent updates to the DatSemShift website and may no longer work.

- **[StatisticalAnalysis.R](StatisticalAnalysis.R)**: Script used for statistical testing.

- **[overall.pdf](overall.pdf)**: Figures included in the abstract.

## Citation

If you use this dataset or code, please cite the following abstract:

> Ürker, E., & Boleda, G. (2026). *On the Prevalence of Different Types of Lexical Semantic Changes: Preliminary Findings*. In **Proceedings of EvoLang 2026**.

```bibtex
@inproceedings{urker2026semanticchange,
  author    = {Ürker, Ecesu and Boleda, Gemma},
  title     = {On the Prevalence of Different Types of Lexical Semantic Changes: Preliminary Findings},
  booktitle = {Proceedings of EvoLang 2026},
  year      = {2026},
  note      = {To appear}
}
```
