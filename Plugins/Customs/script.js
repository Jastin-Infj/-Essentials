$("#run").on("click", () => tryCatch(run));

async function run() {
  try {
    await Excel.run(async (context) => {
      // シート取得
      const inputSheet = context.workbook.worksheets.getItem("構築");
      const outputSheet = context.workbook.worksheets.getItem("翻訳");
      const nameSheet = context.workbook.worksheets.getItem("Name");
      const abilitySheet = context.workbook.worksheets.getItem("特性");
      const itemSheet = context.workbook.worksheets.getItem("アイテム");
      const natureSheet = context.workbook.worksheets.getItem("性格");
      const moveSheet = context.workbook.worksheets.getItem("わざ");
      const typeSheet = context.workbook.worksheets.getItem("タイプ");

      // 入力範囲指定 (例: B2:M10)
      const inputRange = inputSheet.getRange("B2:M100");
      inputRange.load("values");

      // 翻訳シートの出力開始位置
      const outputRange = outputSheet.getRange("B2:M100");

      // 辞書データの取得
      const nameRange = nameSheet.getUsedRange();
      const abilityRange = abilitySheet.getUsedRange();
      const itemRange = itemSheet.getUsedRange();
      const natureRange = natureSheet.getUsedRange();
      const moveRange = moveSheet.getUsedRange();
      const typeRange = typeSheet.getUsedRange();

      nameRange.load("values");
      abilityRange.load("values");
      itemRange.load("values");
      natureRange.load("values");
      moveRange.load("values");
      typeRange.load("values");

      await context.sync();

      // マッピング辞書作成関数
      const createMap = (range) => {
        const map = {};
        range.values.forEach(row => {
          if (row[1] && row[3]) {
            map[row[1].trim()] = row[3].trim();
          }
        });
        return map;
      };

      // 辞書を作成
      const nameMap = createMap(nameRange);
      const abilityMap = createMap(abilityRange);
      const itemMap = createMap(itemRange);
      const natureMap = createMap(natureRange);
      const moveMap = createMap(moveRange);
      const typeMap = createMap(typeRange);

      // ヘルパー関数
      const toHalfWidth = (str) => str.replace(/[０-９]/g, (char) => String.fromCharCode(char.charCodeAt(0) - 0xfee0));
      const addUnderscoreBeforeNumbers = (str) => {
        if (typeof str !== "string") {
          return ""; // nullやundefinedの場合は空文字列を返す
        }
        // アンダースコアを追加し、その後カンマで区切る
        return str.replace(/([A-Za-z]+)(\d+)/g, "$1_$2").split("\n").join(", ");
      };
      const processData = (data, map) => (data || "").split("\n").map(line => {
        const parts = line.split("？");
        if (parts.length === 2) {
          const value = addUnderscoreBeforeNumbers(toHalfWidth(parts[1].trim()));
          return `${map[parts[0].trim()] || "Unknown"}_${value}`;
        }
        return addUnderscoreBeforeNumbers(toHalfWidth(line.trim()));
      }).join(",");

      // データ処理
      const inputData = inputRange.values;
      const outputData = inputData.map(row => [
        nameMap[row[0]] || "NONE",                // B列: 名前
        processData(row[1], abilityMap),          // C列: 特性
        processData(row[2], itemMap),             // D列: アイテム
        processData(row[3], natureMap),           // E列: 性格
        processData(row[4], moveMap),             // F列: わざ1
        processData(row[5], moveMap),             // G列: わざ2
        processData(row[6], moveMap),             // H列: わざ3
        processData(row[7], moveMap),             // I列: わざ4
        processData(row[8], typeMap),             // J列: タイプ
        row[9] || "",                            // K列: ダイマックス
        addUnderscoreBeforeNumbers(row[10] || ""),// L列: 努力値
        addUnderscoreBeforeNumbers(row[11] || "") // M列: 個体値
      ]);

      // 翻訳シートに出力
      outputRange.values = outputData;

      await context.sync();
      console.log("複数行データの処理が完了しました");
    });
  } catch (error) {
    console.error("エラー: ", error);
  }
}

async function tryCatch(callback) {
  try {
    await callback();
  } catch (error) {
    console.error("Error: ", error);
  }
}