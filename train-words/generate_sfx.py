import wave
import struct
import math

def generate_beep(filename, freq_start, freq_end, duration=0.2, volume=0.5, sample_rate=44100):
    n_samples = int(sample_rate * duration)
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)  # mono
        f.setsampwidth(2)  # 16-bit
        f.setframerate(sample_rate)
        
        for i in range(n_samples):
            # LERP frequency for a "swipe" or "ding" effect
            t = i / n_samples
            freq = freq_start + (freq_end - freq_start) * t
            
            # Sine wave generation
            value = math.sin(2 * math.pi * freq * (i / sample_rate))
            
            # Simple envelope (fade out)
            envelope = 1.0 - t
            sample = int(value * volume * envelope * 32767)
            f.writeframesraw(struct.pack('<h', sample))

print("Generating SFX...")
# success: High pitched ascending "ding"
generate_beep("assets/success.wav", 880, 1760, duration=0.15, volume=0.3)
# fail: Low pitched descending "buzz/thud"
generate_beep("assets/fail.wav", 200, 100, duration=0.3, volume=0.5)
print("Done! assets/success.wav and assets/fail.wav created.")
