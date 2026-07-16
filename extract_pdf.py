import fitz  # PyMuPDF
import os

pdf_path = r"c:\Users\user\Desktop\Site de guia do HeyGen\Guia do clone de IA.pdf"
output_dir = r"c:\Users\user\Desktop\Site de guia do HeyGen\images"
os.makedirs(output_dir, exist_ok=True)

doc = fitz.open(pdf_path)
print(f"Total pages: {len(doc)}")

# Extract text from each page
all_text = []
for page_num in range(len(doc)):
    page = doc[page_num]
    text = page.get_text()
    all_text.append(f"\n{'='*60}\nPAGE {page_num + 1}\n{'='*60}\n{text}")
    print(f"\nPage {page_num + 1} text:")
    print(text[:500] if text else "(no text)")

# Save all text
with open(r"c:\Users\user\Desktop\Site de guia do HeyGen\pdf_full_text.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(all_text))

# Extract all images
img_count = 0
for page_num in range(len(doc)):
    page = doc[page_num]
    images = page.get_images(full=True)
    for img_index, img in enumerate(images):
        xref = img[0]
        base_image = doc.extract_image(xref)
        image_bytes = base_image["image"]
        image_ext = base_image["ext"]
        if len(image_bytes) > 2000:  # skip tiny images
            img_count += 1
            img_filename = f"page{page_num+1}_img{img_index+1}.{image_ext}"
            img_path = os.path.join(output_dir, img_filename)
            with open(img_path, "wb") as f:
                f.write(image_bytes)
            print(f"Saved: {img_filename} ({len(image_bytes)} bytes)")

print(f"\nTotal images extracted: {img_count}")
doc.close()
