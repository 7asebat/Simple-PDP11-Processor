const fs = require("fs");

(async () => {
  let file = await fs.readFileSync("control-store.txt", "utf-8");
  let lines = file.split("\n");
  let count = 0;
  lines = lines
    .map((el) => {
      el = el.split("\t").join("");
      el = el.replace("\r", "");
      return el;
    })
    .filter((el) => el !== "")
    .map((el) => {
      el = `${count} => "${el}",`;
      count++;
      return el;
    });

  let output = lines.join("\n");
  await fs.writeFileSync("control-store.out", output);
})();
