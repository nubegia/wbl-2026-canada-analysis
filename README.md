# wbl-2026-canada-analysis

# wbl-2026-canada-analysis

## Overview
This project implements an AI-assisted legal research and evaluation pipeline for the **World Bank’s Women, Business and the Law (WBL) 2026** dataset.

It fulfills **Tasks** of the technical assessment by automating:
- authoritative retrieval of primary legal sources,  
- structured answer generation,  
- evaluator adjudication (second-stage verification), and  
- confidence calibration.

The pipeline uses the **OpenAI GPT-5-mini** model via the Responses API with persistent log storage (`store=True`), exponential-backoff retry logic, and caching for reproducibility.

---

## Architecture
Each question from the input Excel is processed to generate:
1. **A0: Primary legal answer**
   - Structured 4-line output (ANSWER / LAW / LINK / SUMMARY)
   - Confidence score ∈ [0, 1]
   - Latency and run identifier
2. **B5: Evaluator stage**
   - Independent adjudication
   - Verdict (`Correct`, `Incorrect`, `Insufficient Evidence`, or `Outdated Law`)
   - Justification (≤100 words) referencing sources
   - Corrected answer fields (A1) if applicable

---

## Input and Outputs
| File | Description |
|------|--------------|
| `Clean_Fin_Extracted_WBL_Questions_Labor_FinalCleaned.xlsx` | Input questionnaire |
| `*_with_Evals_*.xlsx` / `.csv` | Generated outputs containing A0 and B5 results |

Outputs include:
- AI-generated responses with authoritative laws and URLs  
- Confidence and latency metrics  
- Evaluator verdicts and justifications  
- Timestamps for traceability  

---

