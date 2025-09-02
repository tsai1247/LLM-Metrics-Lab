import os
import json
import pandas as pd
import gspread
from google.oauth2.service_account import Credentials

# usage: python main.py --start-date 20231011-010101 --end-date 20231011-235959
# 解析參數，如果沒有參數的話預設是date.min ~ date.max
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--name", type=str, default="result", help="Name of the export task")
parser.add_argument("--start-date", type=str, default="19700101-000000",
                    help="Start date in format YYYYMMDD-HHMMSS")
parser.add_argument("--end-date", type=str, default="99991231-235959",
                    help="End date in format YYYYMMDD-HHMMSS")
args = parser.parse_args()
name = args.name
start_date = args.start_date
end_date = args.end_date

# Google Sheets 設定
SERVICE_ACCOUNT_FILE = "service_account.json"  # 你的金鑰檔
docid = "1GNDiJuWbTgu_kQlkBav73w8JOQm4bBuKBaWpDgCm7Hk"  # 你的 Google Sheet ID

# 授權
scopes = ["https://www.googleapis.com/auth/spreadsheets"]
creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=scopes)
client = gspread.authorize(creds)

# create new worksheet named "name_start_date_to_end_date"
worksheetname = f"{name}_{start_date} to {end_date}"
spreadsheet = client.open_by_key(docid)
try:
    sheet = spreadsheet.worksheet(worksheetname)
except gspread.exceptions.WorksheetNotFound:
    sheet = spreadsheet.add_worksheet(title=worksheetname, rows="1000", cols="20")

# 遍歷本地資料夾，讀取 parameter.json 和 result.json
base_dir = "/results"  # 你的資料夾路徑
all_data = []

id = 1
for folder in os.listdir(base_dir):
    folder_path = os.path.join(base_dir, folder)
    if os.path.isdir(folder_path):
        for datedir in os.listdir(folder_path):
            # 篩選日期
            if datedir < start_date or datedir > end_date:
                continue

            testcase_path = os.path.join(folder_path, datedir)
            param_path = os.path.join(testcase_path, "parameter.json")
            result_path = os.path.join(testcase_path, "result.json")

            if os.path.exists(param_path) and os.path.exists(result_path):
                with open(param_path, "r", encoding="utf-8") as f:
                    params = json.load(f)
                with open(result_path, "r", encoding="utf-8") as f:
                    result = json.load(f)

                # 合併資料
                row = {**params, **result, "folder": folder}
                # 資料最前面加上id, timestamp
                row = {"id": id, "timestamp": datedir, **row}
                id += 1

                all_data.append(row)

# 轉換為 DataFrame
df = pd.DataFrame(all_data)

# 清空 Google Sheet與所有表格，重新上傳
sheet.clear()
sheet.update([df.columns.values.tolist()] + df.values.tolist())