:import zipfile
import xml.etree.ElementTree as ET
import sys

def read_docx(path):
    with zipfile.ZipFile(path) as docx:
        xml_content = docx.read('word/document.xml')
        tree = ET.XML(xml_content)
        WORD_NAMESPACE = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
        PARA = WORD_NAMESPACE + 'p'
        TEXT = WORD_NAMESPACE + 't'
        text_content = []
        for paragraph in tree.iter(PARA):
            texts = [node.text for node in paragraph.iter(TEXT) if node.text]
            if texts:
                text_content.append(''.join(texts))
        return '\n'.join(text_content)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(read_docx(sys.argv[1]))
