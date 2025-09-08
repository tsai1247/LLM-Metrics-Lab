import os
import json
import pandas as pd
import gspread
from google.oauth2.service_account import Credentials
import os

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

file_path = SERVICE_ACCOUNT_FILE

if not os.path.exists(file_path):
    print('service_account.json not found.  upload to google sheet failed.')
    exit(1)

# 授權
scopes = ["https://www.googleapis.com/auth/spreadsheets"]
creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=scopes)
client = gspread.authorize(creds)

# 遍歷本地資料夾，讀取 parameter.json 和 result.json
base_dir = "/results"  # 你的資料夾路徑
nctu6_data = []
genai_perf_data = []

ncut6_id = 1
genai_perf_id = 1
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
            genai_perf_path = os.path.join(testcase_path, "profile_export_genai_perf.json")

            if os.path.exists(param_path) and os.path.exists(result_path):
                with open(param_path, "r", encoding="utf-8") as f:
                    params = json.load(f)
                with open(result_path, "r", encoding="utf-8") as f:
                    result = json.load(f)

                # 合併資料
                row = {**params, **result, "folder": folder}
                # 資料最前面加上id, timestamp
                row = {"id": ncut6_id, "timestamp": datedir, **row}
                ncut6_id += 1

                nctu6_data.append(row)

            if os.path.exists(param_path) and os.path.exists(genai_perf_path):
                with open(param_path, "r", encoding="utf-8") as f:
                    params = json.load(f)
                with open(genai_perf_path, "r", encoding="utf-8") as f:
                    result = json.load(f)

                # 合併資料
                row = {**params, **result, "folder": folder}

                # 資料最前面加上id, timestamp
                row = {"id": genai_perf_id, "timestamp": datedir, **row}
                genai_perf_id += 1

                genai_perf_data.append(row)

# 移除的欄位
remove_fields = ["input_config", "folder"]
for data in [nctu6_data, genai_perf_data]:
    for row in data:
        for field in remove_fields:
            if field in row:
                del row[field]

def update_sheet(worksheetname, data):
    # 轉換為 DataFrame
    df = pd.DataFrame(data)

    # 清空 Google Sheet與所有表格，重新上傳
    spreadsheet = client.open_by_key(docid)
    try:
        sheet = spreadsheet.worksheet(worksheetname)
    except gspread.exceptions.WorksheetNotFound:
        sheet = spreadsheet.add_worksheet(title=worksheetname, rows="1000", cols="20")

    sheet.clear()
    sheet.update([df.columns.values.tolist()] + df.values.tolist())

def genai_perf_to_sheet_rows(data):
    """
    將 genai_perf_data 轉成兩層表頭格式
    支援單層或雙層 dict
    """
    if not data:
        return [], [], []

    header1 = []
    header2 = []
    values = []

    # 只取第一筆示範表頭
    sample = data[0]
    for k, v in sample.items():
        if isinstance(v, dict):
            for subk in v:
                header1.append(k)
                header2.append(subk)
        else:
            header1.append("-")
            header2.append(k)
    # 每筆資料都要對應 header1/header2
    for row in data:
        row_values = []
        for k, v in sample.items():
            if isinstance(v, dict):
                for subk in v:
                    value = row.get(k, {}).get(subk, "")
                    if isinstance(value, list) or isinstance(value, dict):
                        value = json.dumps(value, ensure_ascii=False)
                    row_values.append(value)
            else:
                value = row.get(k, "")
                if isinstance(value, list) or isinstance(value, dict):
                    value = json.dumps(value, ensure_ascii=False)
                row_values.append(value)
        values.append(row_values)
    return header1, header2, values

def update_sheet_twolevel(worksheetname, data):
    spreadsheet = client.open_by_key(docid)
    try:
        sheet = spreadsheet.worksheet(worksheetname)
    except gspread.exceptions.WorksheetNotFound:
        sheet = spreadsheet.add_worksheet(title=worksheetname, rows="1000", cols="20")
    sheet.clear()
    header1, header2, values = genai_perf_to_sheet_rows(data)
    if header1:
        # 合併 header1 連續相同字串的儲存格
        sheet.append_row(header1)
        col = 1
        while col <= len(header1):
            start = col
            value = header1[col - 1]
            while col <= len(header1) and header1[col - 1] == value:
                col += 1
            end = col - 1
            if end > start and value != "":
                # 合併儲存格
                sheet.merge_cells(f"{gspread.utils.rowcol_to_a1(1, start)}:{gspread.utils.rowcol_to_a1(1, end)}")
        sheet.append_row(header2)
        # header1, header2 兩列都要粗體置中
        sheet.format(f"A1:{gspread.utils.rowcol_to_a1(2, len(header1))}", {"horizontalAlignment": "CENTER", "textFormat": {"bold": True}})
        
        for row in values:
            sheet.append_row(row)

# create new worksheet named "name_start_date_to_end_date"

worksheetname = f"{name}_genai_perf_{start_date} to {end_date}"
update_sheet_twolevel(worksheetname, genai_perf_data)


worksheetname = f"{name}_nctu6_{start_date} to {end_date}"
update_sheet(worksheetname, nctu6_data)