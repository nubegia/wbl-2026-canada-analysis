* ================================================================
* WBL 2026 — WBL Questionnaire Translation (English → Russian)
* ================================================================

clear all
set more off
pause off
mat drop _all

* --- Import Excel with only the Question column ---
import excel "C:\Users\wb611279\OneDrive - WBG\Desktop\AI Test\Clean_Fin_Extracted_WBL_Questions_Labor_FinalCleaned.xlsx", ///
    sheet("Sheet1") firstrow clear
	

* --- Python block for OpenAI translation ---
python
import os, ssl, certifi, httpx, sys, re, time
from openai import OpenAI
from sfi import Data

# ================================================================
# CONFIGURATION
# ================================================================
MODEL               = os.getenv("OPENAI_MODEL", "gpt-5-mini")
API_KEY             = "" 
MAX_OUTPUT_TOKENS   = 4000
HTTP_TIMEOUT_SECS   = 600

if not API_KEY:
    raise RuntimeError("Missing OPENAI_API_KEY – please set your valid key.")

_ctx   = ssl.create_default_context(cafile=certifi.where())
_http  = httpx.Client(verify=_ctx, timeout=HTTP_TIMEOUT_SECS, follow_redirects=True)
client = OpenAI(api_key=API_KEY, http_client=_http)

# ================================================================
# TRANSLATION PROMPT (RUSSIAN ONLY, LABOR-FOCUSED)
# ================================================================
SYSTEM_PROMPT = """
You are a professional legal translator specializing in **labor law**, gender equality,
and employment regulation for the World Bank Group's **Women, Business and the Law (WBL) 2026** project.

Translate each questionnaire question from English into **Russian** in a clear, formal legal-administrative tone.

# Context
These questions relate to:
- Nondiscrimination in employment and recruitment;
- Equal remuneration for work of equal value;
- Maternity, paternity, and parental leave rights;
- Job protection during pregnancy and after return to work;
- Restrictions on working hours and types of work for women;
- Enforcement mechanisms and institutional responsibilities.

# Translation Rules

- Translate precisely and faithfully; do not summarize or simplify.
- Retain question numbers and answer codes (e.g., "01: … | 00: …").
- Translate "Yes" as "Да" and "No" as "Нет".
- Example: "01: Yes | 00: No" → "01: Да | 00: Нет".
- Do not add explanations or interpretations.
- If the input cell is empty, return an empty string.
- Use standard Russian legal style as used in laws and official documents.
- Example patterns:
  "Does the law prohibit discrimination..." → "Запрещает ли законодательство..."
  "Is the employer required..." → "Обязан ли работодатель..."
  "Does the law provide for..." → "Предусматривает ли законодательство..."

# Output Format (STRICT)
Russian Translation: [translated text]
""".strip()

# ================================================================
# HELPER FUNCTIONS
# ================================================================
def _safe_output_text(rsp) -> str:
    """Extract text from model response safely."""
    for attr in ("text", "output_text"):
        val = getattr(rsp, attr, None)
        if isinstance(val, str) and val.strip():
            return val.strip()
    if hasattr(rsp, "output") and isinstance(rsp.output, list):
        acc = []
        for item in rsp.output:
            content = getattr(item, "content", None)
            if isinstance(content, list):
                for c in content:
                    if hasattr(c, "text") and isinstance(c.text, str) and c.text.strip():
                        acc.append(c.text.strip())
        if acc:
            return "\n".join(acc)
    return ""

def call_openai(model: str, original_text: str) -> str:
    """Call OpenAI API to get translation."""
    user_msg = f"Translate this question into Russian:\n\n{original_text}"
    try:
        rsp = client.responses.create(
            model=model,
            input=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_msg},
            ],
            max_output_tokens=MAX_OUTPUT_TOKENS,
            store=True
        )
        return _safe_output_text(rsp)
    except Exception as e:
        sys.stderr.write(f"API call failed: {e}\n")
        return ""

def parse_russian_output(text: str):
    """Extract only Russian translation."""
    if not text or not isinstance(text, str):
        return ""
    m = re.search(r"Russian Translation\s*:\s*(.*)", text, re.S | re.I)
    if m:
        return m.group(1).strip()
    return text.strip()

# ================================================================
# STATA DATA I/O
# ================================================================
N = Data.getObsTotal()

try:
    question_idx = Data.getVarIndex("Question")
except:
    sys.stderr.write("ERROR: 'Question' column not found in dataset.\n")
    sys.exit(1)

try:
    ru_idx = Data.getVarIndex("Russian_Translation")
except:
    Data.addVarStr("Russian_Translation", 9000)
    ru_idx = Data.getVarIndex("Russian_Translation")

# ================================================================
# TRANSLATION LOOP
# ================================================================
for i in range(N):
    question = Data.getAt(question_idx, i)
    if not question or not str(question).strip():
        sys.stderr.write(f"[Row {i+1}] Empty cell – skipped.\n")
        continue

    sys.stderr.write(f"[Row {i+1}] Translating...\n")
    text_to_translate = str(question)

    # fallback truncation if overly long
    if len(text_to_translate) > 3500:
        text_to_translate = text_to_translate[:3500] + " [...]"

    translation = call_openai(MODEL, text_to_translate)
    russian = parse_russian_output(translation)

    if not russian.strip():
        sys.stderr.write(f"[Row {i+1}] Empty output – retrying with gpt-4o-mini...\n")
        russian = parse_russian_output(call_openai("gpt-4o-mini", text_to_translate))

    Data.storeAt(ru_idx, i, russian)
    sys.stderr.write(f"[Row {i+1}] Done.\n")
    time.sleep(1.0)

sys.stderr.write("✅ Translation completed successfully.\n")
end

* --- Export to Excel ---
export excel using "C:\Users\wb611279\OneDrive - WBG\Desktop\AI Test\RussianTranslationWBL.xlsx", ///
    firstrow(variables) replace
