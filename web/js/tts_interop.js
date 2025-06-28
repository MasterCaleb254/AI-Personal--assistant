// web/js/tts_interop.js

// Singleton instance to manage TTS state
const TTSInterop = (() => {
  // Speech synthesis instance
  const synth = window.speechSynthesis;
  let currentUtterance = null;
  let isSpeaking = false;

  // Check browser support
  const isSupported = () => "speechSynthesis" in window;

  // Load available voices (handles async voice loading)
  const getVoices = () =>
    new Promise((resolve) => {
      const voices = synth.getVoices();
      if (voices.length > 0) {
        resolve(voices.map(mapVoice));
        return;
      }

      synth.addEventListener(
        "voiceschanged",
        () => {
          resolve(synth.getVoices().map(mapVoice));
        },
        { once: true }
      );
    });

  // Voice data mapper
  const mapVoice = (voice) => ({
    name: voice.name,
    lang: voice.lang,
    localService: voice.localService,
    default: voice.default,
  });

  // Speak text with options
  const speak = (text, options = {}) => {
    return new Promise((resolve, reject) => {
      if (!isSupported()) {
        reject(new Error("TTS not supported in this browser"));
        return;
      }

      cancel(); // Stop any ongoing speech

      currentUtterance = new SpeechSynthesisUtterance(text);
      currentUtterance.rate = options.rate || 1.0;
      currentUtterance.pitch = options.pitch || 1.0;
      currentUtterance.volume = options.volume || 1.0;

      // Set voice if specified
      if (options.voiceName) {
        getVoices().then((voices) => {
          const voice = voices.find((v) => v.name === options.voiceName);
          if (voice)
            currentUtterance.voice = synth
              .getVoices()
              .find((v) => v.name === voice.name);
        });
      }

      // Event handlers
      currentUtterance.onstart = () => {
        isSpeaking = true;
        if (options.onStart) options.onStart();
      };

      currentUtterance.onend = () => {
        isSpeaking = false;
        resolve();
      };

      currentUtterance.onerror = (event) => {
        isSpeaking = false;
        reject(new Error(`TTS Error: ${event.error}`));
      };

      synth.speak(currentUtterance);
    });
  };

  // Control methods
  const pause = () => (synth.paused ? null : synth.pause());
  const resume = () => (synth.paused ? synth.resume() : null);
  const cancel = () => {
    if (synth.speaking) synth.cancel();
    isSpeaking = false;
  };
  const speaking = () => isSpeaking;

  return {
    isSupported,
    getVoices,
    speak,
    pause,
    resume,
    cancel,
    speaking,
  };
})();

// Expose to Dart interop
window.TTSBridge = {
  isSupported: () => TTSInterop.isSupported(),

  getVoices: () =>
    new Promise((resolve) => {
      TTSInterop.getVoices().then((voices) => resolve(voices));
    }),

  speak: (text, voiceName, rate) =>
    new Promise((resolve, reject) => {
      TTSInterop.speak(text, {
        voiceName,
        rate,
        onStart: () => resolve("started"),
      }).catch(reject);
    }),

  pause: () => TTSInterop.pause(),
  resume: () => TTSInterop.resume(),
  cancel: () => TTSInterop.cancel(),
  isSpeaking: () => TTSInterop.speaking(),
};
