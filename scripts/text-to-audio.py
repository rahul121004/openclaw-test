#!/usr/bin/env python3
"""Convert text file to audio using Google TTS (free, no API key needed)"""

import sys
from gtts import gTTS

def convert_text_to_audio(text_file, output_file, lang='en'):
    """Convert text file to MP3 audio"""
    try:
        # Read text file
        with open(text_file, 'r', encoding='utf-8') as f:
            text = f.read().strip()
        
        if not text:
            print("Error: Text file is empty")
            return False
        
        print(f"📖 Reading: {text_file}")
        print(f"📝 Text length: {len(text)} characters")
        
        # Convert to speech
        print("🎤 Converting to speech...")
        tts = gTTS(text=text, lang=lang, slow=False)
        
        # Save audio file
        print(f"💾 Saving: {output_file}")
        tts.save(output_file)
        
        print(f"✅ Done! Audio saved to: {output_file}")
        return True
        
    except FileNotFoundError:
        print(f"❌ Error: File not found: {text_file}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 text-to-audio.py <text_file> [output_file] [language]")
        print("Example: python3 text-to-audio.py ~/document.txt ~/document.mp3 en")
        print("\nSupported languages: en, hi, es, fr, de, it, pt, ru, ja, ko, zh, etc.")
        sys.exit(1)
    
    text_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else text_file.rsplit('.', 1)[0] + '.mp3'
    lang = sys.argv[3] if len(sys.argv) > 3 else 'en'
    
    success = convert_text_to_audio(text_file, output_file, lang)
    sys.exit(0 if success else 1)
