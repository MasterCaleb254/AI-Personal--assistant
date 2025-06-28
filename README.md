# 🧠 AI-Personal--Assistant 🤖

> Your voice-enabled, GPT-powered personal assistant — in your pocket, on any platform.

---

## 🎯 Features

- 🗣️ **Voice Input** (via Whisper or native STT)
- 💬 **GPT-4 Agent(s)** — with memory + personas
- 🔊 **TTS Output** using Google, Polly, or offline engines
- 🎨 **Themes, Prompts, Multi-agent Support**
- 💾 **Session Memory** via Drift (SQLite)
- 🌐 **Flutter Web Companion** (JS interop for STT/TTS)
- 📦 **Embeddings & Vector DB** (for semantic memory)
- 🔧 **Platform Channels** (for native voice, calendar APIs)

---

## 📁 Folder Structure

```bash
lib/src/
├── agents/            # GPT, local, on-device agents
├── api/               # OpenAI, Whisper, TTS clients
├── data/              # Drift DB, models, vector DB
├── features/          # Chat, memory, settings, voice
├── services/          # App-wide services
├── utils/             # Native bridges, logger, errors
├── widgets/           # Chat bubble, voice button, etc.
🛠️ Tech Stack
Flutter + Dart

OpenAI GPT-4 / LLM

Whisper STT / TTS APIs

Drift (local DB)

FAISS / Chroma (embeddings)

Figma (for design assets)

CI/CD with GitHub Actions

🚀 Getting Started
bash
Copy
Edit
git clone https://github.com/MasterCaleb254/AI-Personal--assistant.git
cd AI-Personal--assistant
flutter pub get
flutter run
🧪 Tests
bash
Copy
Edit
flutter test
📦 CI/CD & GitHub Actions (Next Step)
✅ Auto Linting

✅ Test Runs on PR

✅ Build APK/Web on Push

Coming soon.

📸 UI Previews
Add screenshots or Loom demo here soon.

🙌 Contributing
Pull requests are welcome! For major changes, open an issue first.

📄 License
MIT

