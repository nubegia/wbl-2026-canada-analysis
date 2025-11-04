

# WBL-2026 AI Pipeline 

## Overview

This repository implements an **AI-assisted workflow** for the **World Bank’s Women, Business and the Law (WBL) 2026** project.
It automates legal analysis, translation, and questionnaire enhancement using OpenAI models integrated with Stata and Python.

---

## Completed Tasks

| Task                                   | Goal                                                                  | Model                  | Output                                                                                               |
| -------------------------------------- | --------------------------------------------------------------------- | ---------------------- | ---------------------------------------------------------------------------------------------------- |
| **Task B — Legal Answer + Evaluator**  | Generate authoritative legal answers and adjudications                | `gpt-5-mini`           | `Clean_Fin_Extracted_WBL_Questions_Labor_FinalCleaned_CANADA_with_Evals_20251104_151351.xlsx / .csv` |
| **Task D — Questionnaire Enhancement** | Improve clarity and policy value of Labor-topic questions             | `gpt-5-mini`           | `EnhancedQuestionnaireWBL.xlsx`                                                                      |
| **Task E — AI Translator**             | Translate WBL questions into Russian with full structure preservation | `gpt-5-nano / 4o-mini` | `RussianTranslationWBL.xlsx`                                                                         |

---

## Pipeline Summary

1. **Legal Module (A0 + B):** Structured output with `ANSWER / LAW / LINK / SUMMARY`, verdicts, and confidence.
2. **Enhancement Module:** Reviews and rephrases WBL Labor questions for clarity and alignment.
3. **Translation Module:** Produces accurate Russian translations, keeping codes and numbering intact.

---

##  Repository Files

| File                                                                                                 | Description                                        |
| ---------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `Fin_Extracted_WBL_Questions_Labor_FinalCleaned.xlsx`                                                | Input questionnaire                                |
| `Clean_Fin_Extracted_WBL_Questions_Labor_FinalCleaned_CANADA_with_Evals_20251104_151351.xlsx / .csv` | Legal answer + evaluation outputs                  |
| `EnhancedQuestionnaireWBL.xlsx`                                                                      | Enhanced Labor questionnaire                       |
| `RussianTranslationWBL.xlsx`                                                                         | Russian translations                               |
| `Questionnaire Enhancement Code.do`                                                                  | Stata + Python code for Task D                     |
| `Do file WBL Russian Translation.do`                                                                 | Stata + Python code for Task E                     |
| `Task A Final.ipynb` / `Task B Final.ipynb`                                                          | Jupyter notebooks for legal and evaluation modules |
| `.dta` files                                                                                         | Processed datasets for Stata integration           |

---

## Features

* Deterministic `gpt-5-mini` Responses API with `store=True`
* Secure HTTP requests via `httpx + certifi`
* Stata-Python integration for batch runs
* Structured logging and reproducibility

---

## Run Locally

```bash
pip install openai httpx certifi pandas
setx OPENAI_API_KEY "your_api_key_here"
```

In **Stata**:

```stata
import excel "Clean_Fin_Extracted_WBL_Questions_Labor_FinalCleaned.xlsx", firstrow clear
python
# paste module code
end
```

---



