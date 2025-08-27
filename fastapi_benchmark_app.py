from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from typing import List, Dict
import asyncio
import threading
import subprocess

from config.settings import (
    LOG_FILE_DIR,
    STATIC_DIR,
    HOST,
    HTTP_PORT,
)

app = FastAPI(title="LLM Benchmark App")

# 固定的 Benchmark 與 Engine 設定
BENCHMARKS = ["genai-perf", "LLM_Metrics"]
ENGINES = ["uifw-s0410", "uifw-l090", "vllm"]
TARGET_MODELS = [ "Qwen/Qwen3-30B-A3B-Instruct-2507", "Qwen/Qwen3-0.6B" ]  # 你可以根據實際情況修改

BENCHMARK = BENCHMARKS[0]
ENGINE = ENGINES[0]
CURRENT_MODEL: list

benchmark_params: List[Dict] = []
engine_params: List[Dict] = []
combinations: List[Dict] = []
execution_log: List[str] = []
detail_log: List[str] = []

class BenchmarkParam(BaseModel):
    concurrent: int
    time_limit: int
    input_tokens: str
    output_tokens: str

class EngineParam(BaseModel):
    gpu: str

class Combination(BaseModel):
    model: BenchmarkParam
    benchmark: BenchmarkParam
    engine: EngineParam

class DeleteCombinationParam(BaseModel):
    index: int

# -- simple frontend --
@app.get("/", response_class=HTMLResponse)
async def get_index():
    index_file = STATIC_DIR / "appmain.html"
    return index_file.read_text(encoding="utf-8")

@app.get("/models/available")
def get_models():
    return {"models": TARGET_MODELS}

@app.get("/models")
def get_models():
    return {"models": CURRENT_MODEL}

@app.post("/models")
def set_models(data: Dict):
    global CURRENT_MODEL
    models = data.get("models", [])
    if isinstance(models, list):
        CURRENT_MODEL = models
    else:
        CURRENT_MODEL = [ models ]
    return {"message": f"Current model(s) set to {CURRENT_MODEL}"}

@app.get("/config/options")
def get_config_options():
    return {"benchmarks": BENCHMARKS, "engines": ENGINES}

@app.get("/config")
def get_config():
    return {"benchmark": BENCHMARK, "engine": ENGINE}

@app.post("/config")
def set_config(data: Dict):
    global BENCHMARK, ENGINE
    BENCHMARK = data.get("benchmark", BENCHMARK)
    ENGINE = data.get("engine", ENGINE)
    return {"message": "Config updated", "benchmark": BENCHMARK, "engine": ENGINE}

@app.get("/input/benchmark")
def get_benchmark_params():
    return {"data": benchmark_params}

@app.post("/input/benchmark")
def set_benchmark_params(params: List[BenchmarkParam]):
    global benchmark_params
    benchmark_params = [p.dict() for p in params]
    return {"message": "Benchmark params updated", "data": benchmark_params}

@app.get("/input/engine")
def get_engine_params():
    return {"data": engine_params}

@app.post("/input/engine")
def set_engine_params(params: List[EngineParam]):
    global engine_params
    engine_params = [p.dict() for p in params]
    return {"message": "Engine params updated", "data": engine_params}

@app.get("/combination")
def get_combinations():
    return {"combinations": combinations}

@app.post("/combination")
def generate_combinations():
    global combinations
    combinations = []
    for m in CURRENT_MODEL:
        for b in benchmark_params:
            for e in engine_params:
                combinations.append({"model": m, "benchmark": b, "engine": e})
    return {"combinations": combinations}

@app.delete("/combination")
def remove_combination(params: DeleteCombinationParam):
    global combinations
    print(params.index)
    print(combinations)
    if 0 <= params.index < len(combinations):
        combinations.pop(params.index)
        return {"message": "Combination removed", "remaining": combinations}
    else:
        raise HTTPException(status_code=400, detail="Invalid index")

async def run_single_combination(combo, idx):
    # TODO
    execution_log.append(f"[進度{idx+1}/{len(combinations)}] 開始執行組合 {combinations[idx]} ")
    detail_log.append(f"[細節] 啟動 {ENGINE} with {combo['engine']}")
    if ENGINE == "uifw-s0410":
        print(combo)
        model = combo['model']
        model_series = model.split('/')[0]
        model_name = model.split('/')[1]
        tp = combo['engine']['gpu']
        # run scripts/engine/uifw-s0410/run.sh 
        cmd = f"bash ./scripts/engine/uifw-s0410/run.sh --model-series {model_series} --model-name {model_name} --tp {tp}"

        def run_cmd():
            subprocess.run(cmd, shell=True)
        thread = threading.Thread(target=run_cmd)
        thread.start()

    # await asyncio.sleep(5)  # 模擬推理引擎啟動
    # detail_log.append(f"[細節] 執行 {BENCHMARK} with {combo['benchmark']}")
    # await asyncio.sleep(5)  # 模擬 benchmark 執行

@app.post("/execute/start")
async def start_execution():
    global execution_log, detail_log
    execution_log = []
    detail_log = []

    if not combinations:
        raise HTTPException(status_code=400, detail="No combinations to execute")

    for idx, combo in enumerate(combinations):
        await run_single_combination(combo, idx)

    return {"message": "Execution completed"}

@app.get("/execute/log")
def get_execution_log():
    return {"execution_log": execution_log}

@app.get("/execute/detail_log")
def get_detail_log():
    return {"detail_log": detail_log}

@app.get("/visualization")
def visualization():
    # 這裡可以整合 matplotlib 或 plotly 繪圖，回傳圖表連結或 base64
    return {"message": "Visualization not implemented yet"}

@app.post("/export/local")
def export_local():
    # 寫入 CSV 或 JSON 的邏輯可在這裡實作
    return {"message": "Export to local not implemented yet"}

@app.post("/export/wandb")
def export_wandb():
    # 寫入 wandb 的邏輯可在這裡實作
    return {"message": "Export to WandB not implemented yet"}
