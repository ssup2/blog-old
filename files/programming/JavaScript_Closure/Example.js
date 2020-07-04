function outerFunc(x) {
    var y = 10;

    var innerFunc = function () { 
        return x + y  
    };
    return innerFunc;
}
  
var add10 = outerFunc(10);
var add20 = outerFunc(20);
var add30 = outerFunc(30);

console.log(add10()); // 10
console.log(add20()); // 20
console.log(add30()); // 30

