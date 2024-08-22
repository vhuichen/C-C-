var fs = require("fs");

// 同步读取数据
var data = fs.readFileSync('input.txt');
console.log(data.toString());
console.log("同步读取数据：程序执行结束!");

// 异步读取数据
fs.readFile('input.txt', function (err, data) {
    if (err) return console.error(err);
    console.log(data.toString());
});
console.log("异步读取数据：程序执行结束!");
