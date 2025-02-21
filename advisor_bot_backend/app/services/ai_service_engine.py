import openai
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

if not OPENAI_API_KEY:
    raise ValueError("❌ OPENAI_API_KEY is missing in the .env file. Please add it.")

# Initialize OpenAI Client (New Method)
client = openai.OpenAI(api_key=OPENAI_API_KEY)

def ask_ai(question: str, knowledge_base: str = "") -> str:
    """
    Sends a question to OpenAI's GPT model with relevant financial knowledge.

    :param question: The user's query.
    :param knowledge_base: Additional context to improve the AI's response.
    :return: AI-generated response as a string.
    """
    prompt = f"""
    Based on the following financial knowledge, provide a response:

    {knowledge_base}

    User Question: {question}
    """

    try:
        response = client.chat.completions.create(
            model="gpt-4",  # Ensure model name is correct
            messages=[
                {"role": "system", "content": "You are a financial advisor. Provide insightful and accurate responses."},
                {"role": "user", "content": prompt.strip()}
            ]
        )
        return response.choices[0].message.content.strip()

    except openai.OpenAIError as e:
        return f"❌ OpenAI API Error: {e}"

    except Exception as e:
        return f"❌ Error processing request: {e}"
