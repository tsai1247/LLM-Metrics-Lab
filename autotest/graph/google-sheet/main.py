import argparse
import math
import matplotlib.pyplot as plt
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import pandas as pd
from datetime import datetime

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--worksheet', required=True)
    parser.add_argument('--target', required=True)
    parser.add_argument('--type', required=True) # genai-perf or nctu6
    parser.add_argument('--service-account', required=True)
    args = parser.parse_args()
    print('yo', args.worksheet, args.target, args.type, args.service_account)

    scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
    credentials = ServiceAccountCredentials.from_json_keyfile_name(args.service_account, scope)
    gc = gspread.authorize(credentials)
    sheet = gc.open_by_key('1GNDiJuWbTgu_kQlkBav73w8JOQm4bBuKBaWpDgCm7Hk').worksheet(args.worksheet)

    rows = sheet.get_all_values()

    if args.type == 'genai-perf':
        header1 = rows[0]
        header2 = rows[1]
        columns = []
        h1 = ''
        for idx in range(len(header2)):
            h1 = header1[idx] if header1[idx] else h1
            if h1 == '-':
                h1 = ''
            h2 = header2[idx]
            if h1 and h2:
                columns.append(f"{h1.strip()}.{h2.strip()}")
            elif h2:
                columns.append(h2.strip())
            else:
                columns.append(h1.strip())

        df = pd.DataFrame(rows[2:], columns=columns)
    
    else:
        df = pd.DataFrame(rows[1:], columns=rows[0])

    # df 依照 concurrency 數字排序
    if 'concurrency' in df.columns:
        df['concurrency'] = pd.to_numeric(df['concurrency'], errors='coerce')
        df = df.sort_values(by='concurrency')

    for basic_col in ['engine', 'benchmark', 'concurrency', 'model_name']:
        if basic_col not in df.columns:
            df[basic_col] = 'vllm' if basic_col == 'engine' else 'unknown'

    target = args.target
    df[target] = pd.to_numeric(df[target], errors='coerce')
    df = df.dropna(subset=[target])

    unique_models = df['model_name'].unique()
    num_models = len(unique_models)

    rows = 2
    cols = math.ceil(num_models / rows)
    fig, axes = plt.subplots(rows, cols, figsize=(6*cols, 4*rows))
    axes = axes.flatten()

    for idx, model in enumerate(unique_models):
        ax = axes[idx]
        group = df[df['model_name'] == model]
        pivot = group.pivot_table(index='concurrency', columns='engine', values=args.target, aggfunc='mean')
        pivot.plot(kind="bar", ax=ax)
        ax.set_title(model)
        ax.set_ylabel(args.target)
        ax.set_xlabel('Concurrency')
        ax.set_xticks(range(len(pivot.index)))
        ax.set_xticklabels([str(int(x)) for x in pivot.index])
        ax.legend(title='Engine')
        ax.grid(True)

    for idx in range(len(unique_models), len(axes)):
        fig.delaxes(axes[idx])

    fig.suptitle(f"{args.worksheet} - {args.target}", fontsize=16)
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    # plt.show()
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    title = fig._suptitle.get_text() if fig._suptitle else "figure"
    filename = f"./{title}_{timestamp}.png"
    plt.savefig(filename)
    print(f"Figure saved to {filename}")

if __name__ == "__main__":
    main()
