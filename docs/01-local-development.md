# Local Development & Execution Guide: freeOCR.me

This guide provides instructions for developers, testers, and reviewers on how to run, test, and debug the **freeOCR.me** application locally.

---

## 1. Prerequisites

Ensure the following tools are installed on your machine:
- **Python 3.13+** (`python --version`)
- **Flutter SDK 3.44+** (`flutter --version`)
- **Git** (`git --version`)

---

## 2. Setting Up Backend Environment (`src/backend`)

1. Open a terminal in the project root directory `freeOcr/`.
2. Navigate to the backend folder or use python directly:
   ```powershell
   # Create virtual environment (optional)
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1

   # Install dependencies
   pip install -r src/backend/requirements.txt
   ```

3. **Starting the FastAPI Uvicorn Server:**
   ```powershell
   # From workspace root
   python -m uvicorn src.backend.app.main:app --reload --port 8000
   ```
   - **API Docs (Swagger UI):** Visit `http://127.0.0.1:8000/docs`
   - **Health Check Probe:** Visit `http://127.0.0.1:8000/api/v1/health`
   - **Runtime Config Endpoint:** Visit `http://127.0.0.1:8000/api/v1/config`

---

## 3. Setting Up Frontend Web Client (`src/frontend`)

1. Open a terminal in the project root directory `freeOcr/`.
2. Navigate to `src/frontend`:
   ```powershell
   cd src/frontend
   flutter pub get
   ```

3. **Running Flutter Web in Chrome:**
   ```powershell
   flutter run -d chrome
   ```
   - The app will launch automatically in Chrome with hot reload enabled.

---

## 4. Running Automated Verification Suites

### Backend Unit & Integration Tests (`pytest`)
```powershell
# From workspace root
python -m pytest src/tests/ -v
```

### Frontend Code Analysis & Widget Tests (`flutter analyze` / `flutter test`)
```powershell
cd src/frontend
flutter analyze
flutter test
```
