# AML YR 26 — Lab 2: Messy Data & Leakage-Safe Features

DSA 8401 Applied Machine Learning (Chapter 2). Worked solution for Lab 2 on a synthetic
mobile-money transaction dump: audit the mess, clean and aggregate it, hunt the leak, and
wrap everything in a leakage-safe scikit-learn pipeline.


---

git fetch upstream

git merge upstream/master

git push origin master


Listed directory lab10_fastapi
Listed directory AML_Book-Data
Viewed docker-compose.yml:1-24
Viewed .TXT:1-5
Listed directory mlflow_simple
Listed directory fraud_mlops
Viewed README.md:1-100
Viewed README.md:101-157
Viewed train_mlflow.py:1-60
Viewed Docker.md:1-100
Listed directory scripts
Viewed Dockerfile:1-15
Viewed Dockerfile.deeplearning:1-43
Viewed start_deeplearning.sh:1-69
Searched for "mlflow"
Viewed requirements.txt:1-8

Here is how you can access **MLflow** and **Docker** in this repository:

---

### 1. Accessing MLflow

Experiments in this project log metrics, parameters, and models into a local SQLite database (`mlflow.db`). To open the MLflow dashboard:

#### For `lab10_fastapi` (current workspace file: [train_mlflow.py](file:///Users/leonida/Documents/AML_Book-Data/lab10_fastapi/train_mlflow.py)):
1. **Run the training script** (if you haven't yet):
   ```bash
   cd lab10_fastapi
   python train_mlflow.py
   ```
2. **Launch the MLflow UI**:
   ```bash
   mlflow ui --backend-store-uri sqlite:///mlflow.db --port 5000
   ```
3. **Open in browser**:
   👉 **[http://127.0.0.1:5000](http://127.0.0.1:5000)** (view experiment `lab10_fraud` and model registry `lab10_fraud_model`).

#### For other MLflow folders:
* **`mlflow_simple/`**:
  ```bash
  cd mlflow_simple
  mlflow ui --backend-store-uri sqlite:///mlflow.db
  ```
* **`fraud_mlops/`**:
  ```bash
  cd fraud_mlops
  mlflow ui --backend-store-uri sqlite:///mlflow.db
  ```

*(If port 5000 is occupied, add `--port 5001` and access at `http://127.0.0.1:5001`)*.

---

### 2. Accessing Docker

As outlined in your project's [Docker.md](file:///Users/leonida/Documents/AML_Book-Data/Docker.md) guide, everything can be managed headlessly from the terminal:

#### Step 1: Start the Docker Daemon
Run your shell alias:
```bash
docker-start
# Verify it is running:
docker-status
```

#### Step 2: Spin Up the AML Deep Learning Container (Jupyter + TF)
Using the repository's launcher:
```bash
./scripts/start_deeplearning.sh
```
*or via compose directly:*
```bash
docker compose up -d
```
* **Open Jupyter Lab in browser**: 👉 **[http://localhost:8888](http://localhost:8888)**
* **Follow live logs**: `docker compose logs -f` (or alias `dcl`)
* **Stop container**: `./scripts/start_deeplearning.sh --stop` (or `docker compose down` / alias `dcd`)

#### Step 3: Fraud MLOps API Container (`fraud_mlops/`)
If you want to run the FastAPI service containerized:
```bash
cd fraud_mlops
docker build -t fraud-api .
docker run -d -p 8000:8000 --name fraud-api fraud-api
```
* **Open Swagger Docs in browser**: 👉 **[http://localhost:8000/docs](http://localhost:8000/docs)**











## Contents

| Path | What it is |
|---|---|
| `Data/mobile_money_statements.csv` | Synthetic mobile-money transactions (~183k rows, 18 columns, `is_fraud` target) |
| `Data/mobile_transt.txt` | Data dictionary for the CSV |
| `notebook/lab2_solution.ipynb` | The full worked solution |

## The four tasks

1. **Audit** — missingness per column, exact duplicates, validity violations, and an
   MCAR / MAR / MNAR classification for each incomplete column (`agent_id` = MAR,
   `device_id` = MCAR, `gps_lat`/`gps_lon` = MNAR).
2. **Clean & aggregate** — deduplicate, parse the string `amount` (`"1,500/-"`,
   `"(227/-)"`, `"4,742/- Dr"`) and the three `txn_time` formats, resolve entities to a
   canonical `customer_id` via `reg_id`, then build customer-level RFM, ratio and cyclical
   features as of `SCORING_TS`.
3. **Hunt the leak** — correlation screen plus a lineage argument identifying
   `manual_review_score` and `settlement_status` as post-outcome fields.
4. **Pipeline** — one `ColumnTransformer` + `Pipeline` evaluated with `GroupKFold` grouped
   by `customer_id`, scored with and without the leaky columns.

**Headline result:** ROC–AUC is ~0.63 on the honest feature set and ~1.00 once the leaky
columns are added — roughly +0.37 of pure illusion, since those fields are only written
*after* a transaction is scored.

## Running it

```bash
pip install pandas numpy scikit-learn jupyter
jupyter notebook notebook/lab2_solution.ipynb
```

Note: the load cell currently uses an absolute path to `Data/mobile_money_statements.csv` —
change it to a relative path if you clone this elsewhere.


