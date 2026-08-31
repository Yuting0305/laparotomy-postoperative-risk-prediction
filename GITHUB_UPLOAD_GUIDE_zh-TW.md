# GitHub與Zenodo上傳步驟

## 上傳前修改

1. 開啟`CITATION.cff`。
2. 將`AUTHOR_FAMILY_NAME`與`AUTHOR_GIVEN_NAME`改成作者英文姓名。
3. 將`USERNAME/REPOSITORY`改成實際GitHub帳號與Repository名稱。
4. 確認已取得院方及共同作者同意公開程式。

## 建立GitHub Repository

1. 登入GitHub。
2. 點右上角`+`，選擇`New repository`。
3. Repository name建議填寫`laparotomy-postoperative-risk-code`。
4. 選擇`Public`。
5. 不要另外建立README、.gitignore或License。
6. 點`Create repository`。

## 上傳檔案

1. 解壓縮本套件。
2. 在GitHub Repository點`Add file`，再點`Upload files`。
3. 上傳解壓縮後資料夾內的全部內容，不要只上傳ZIP檔。
4. Commit message填寫`Initial public release`。
5. 點`Commit changes`。

## 公開前確認

GitHub不可出現下列內容：

- `data/input_data.csv`
- 原始臨床資料
- 病歷號或其他身分識別資料
- train/test資料集
- 個別預測機率
- PKL或Joblib模型檔
- `outputs`資料夾
- 個人電腦或院內絕對路徑

## 連接Zenodo並建立DOI

1. 登入Zenodo並連接GitHub帳號。
2. 在Zenodo的GitHub頁面點`Sync now`。
3. 找到本Repository並開啟連接。
4. 回到GitHub，點`Releases`，再點`Create a new release`。
5. Tag填寫`v1.0.0`。
6. Release title填寫`Version 1.0.0 – Manuscript analysis code`。
7. 點`Publish release`。
8. 等待Zenodo封存並產生DOI。
9. 將DOI補入README、CITATION.cff及論文。
