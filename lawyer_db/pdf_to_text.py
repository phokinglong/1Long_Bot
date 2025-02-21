import os
import pdfplumber

# Adjust these folder names to match your structure
PDF_FOLDER = "pdfs"       # Folder containing your PDFs
TEXT_FOLDER = "texts"     # Folder to store the .txt outputs

def convert_pdf_to_text(pdf_path, txt_output_path):
    """
    Uses pdfplumber to convert a PDF to raw text and save it to a .txt file.
    """
    with pdfplumber.open(pdf_path) as pdf:
        pages_text = []
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                pages_text.append(text)

    full_text = "\n".join(pages_text)
    
    # Save to .txt file
    with open(txt_output_path, "w", encoding="utf-8") as f:
        f.write(full_text)
    print(f"Converted {pdf_path} -> {txt_output_path}")

def main():
    # Create texts folder if it doesn't exist
    if not os.path.exists(TEXT_FOLDER):
        os.makedirs(TEXT_FOLDER)
    
    # Go through every PDF in the PDF_FOLDER
    for file_name in os.listdir(PDF_FOLDER):
        if file_name.lower().endswith(".pdf"):
            pdf_path = os.path.join(PDF_FOLDER, file_name)
            txt_file_name = file_name.replace(".pdf", ".txt")
            txt_output_path = os.path.join(TEXT_FOLDER, txt_file_name)

            # Convert
            convert_pdf_to_text(pdf_path, txt_output_path)

if __name__ == "__main__":
    main()
