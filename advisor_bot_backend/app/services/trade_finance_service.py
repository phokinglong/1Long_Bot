import os
import openai
from typing import Dict
from app.schemas.trade_finance_schema import TradeFinanceInput, TradeFinanceOutput

PROMPTS: Dict[int, str] = {
    1: "Analyze potential geopolitical and financial risks for an export from {origin} to {destination} for {commodity}, invoice ${amount}.",
    2: "Propose the best payment structure (e.g., LC, open account) given the details: shipping {commodity} from {origin} to {destination}, invoice of ${amount}.",
    3: "Check if trading {commodity} from {origin} to {destination} for ${amount} is subject to any international sanctions or restrictions.",
    4: "Recommend the best Incoterm for shipping {commodity} from {origin} to {destination}, invoice ${amount}, focusing on cost-sharing and risk distribution.",
    5: "Suggest ideal insurance coverage for shipping {commodity} from {origin} to {destination}, invoice of ${amount}, highlighting risk factors.",
    6: "Outline a freight forwarding strategy, considering shipping lanes, cost, and reliability for {commodity} from {origin} to {destination}, invoice: ${amount}.",
    7: "Describe the due diligence steps for {commodity} trade between {origin} and {destination}, invoice ${amount}, focusing on compliance and AML checks.",
    8: "List essential documents required for {commodity} shipment from {origin} to {destination}, invoice ${amount} (e.g., B/L, invoice, packing list).",
    9: "Given {commodity} from {origin} to {destination}, invoice ${amount}, propose credit terms that balance risk and liquidity for both buyer and seller.",
    10: "Assess if the trade in {commodity} from {origin} to {destination}, invoice ${amount}, qualifies for green or sustainable finance programs."
}

def build_prompt(input_data: TradeFinanceInput) -> str:
    """
    Insert user data into the chosen prompt.
    """
    template = PROMPTS.get(input_data.prompt_id, "Unknown prompt selected.")
    return template.format(
        origin=input_data.origin_country,
        destination=input_data.destination_country,
        commodity=input_data.commodity_description,
        amount=f"{input_data.invoice_amount:,.2f}"
    )

def call_openai_llm(prompt_text: str) -> str:
    """
    Call the OpenAI ChatCompletion API using the user's environment-provided API key.
    """
    openai.api_key = os.environ.get("OPENAI_API_KEY")
    if not openai.api_key:
        return "[Error] OPENAI_API_KEY environment variable not set."

    try:
        response = openai.chat.completions.create(
            model="gpt-4",  # or "gpt-3.5-turbo"
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful trade finance advisor."
                },
                {
                    "role": "user",
                    "content": prompt_text
                }
            ],
            max_tokens=1000,
            temperature=0.7
        )
        # The assistant’s response is now stored in 'response.choices[0].message.content'
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"[OpenAI API Error] {e}"

def get_trade_finance_advice(input_data: TradeFinanceInput) -> TradeFinanceOutput:
    """
    Build the final prompt, call the real OpenAI LLM, and return the response.
    """
    final_prompt = build_prompt(input_data)
    ai_resp = call_openai_llm(final_prompt)
    prompt_label = f"Prompt #{input_data.prompt_id}"

    return TradeFinanceOutput(
        prompt_used=prompt_label,
        combined_prompt=final_prompt,
        ai_response=ai_resp
    )
