$("#run").on("click", () => tryCatch(run));

async function run() {
  try {
    await Excel.run(async (context) => {
      // シート取得
      const inputSheet = context.workbook.worksheets.getItem("翻訳");
      const outputSheet = context.workbook.worksheets.getItem("Copy");

      // 入力範囲を指定 (B2:M100)
      const inputRange = inputSheet.getRange("B2:M100");
      inputRange.load("values");

      await context.sync();

      // データの読み取り
      const inputData = inputRange.values;

      // データを指定フォーマットに整形
      const formattedData = inputData.map((row, index) => {
        if (row[9] === true) row[9] = "TRUE";
        if (row[9] === false) row[9] = "FALSE";
        return `#-------------------------------
[${index}]
species = ${row[0] || "UNKNOWN"}
ability_rand = ${row[1] ?.replace(/\n/g, ",") || ""}
items_rand = ${row[2] ?.replace(/\n/g, ",") || ""}
nature = ${row[3] || ""}
move1_rand = ${row[4] ?.replace(/\n/g, ",") || ""}
move2_rand = ${row[5] ?.replace(/\n/g, ",") || ""}
move3_rand = ${row[6] ?.replace(/\n/g, ",") || ""}
move4_rand = ${row[7] ?.replace(/\n/g, ",") || ""}
evs = ${row[10] ?.replace(/\n/g, ",") || ""}
ivs_core = ${row[11] ?.replace(/\n/g, ",") || ""}
dynamaxlv = ${row[9] || ""}
teras_rand = ${row[8] ?.replace(/\n/g, ",") || ""}`;
      });

      // 各データを行ごとに出力 (B2, B3, B4...)
      formattedData.forEach((data, i) => {
        const outputCell = outputSheet.getRange(`B${i + 2}`); // 出力行を動的に設定
        outputCell.values = [[data]];
      });

      await context.sync();
      console.log("データの整形と出力が完了しました。");
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