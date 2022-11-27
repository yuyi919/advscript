import { Cache, createTextTypography } from ".";
let txt =
  "Commodo fugiat amet excepteur commodo eu nisi duis culpa magna dolor sunt nostrud ullamco. Quis ea cupidatat esse sit duis aute reprehenderit nostrud reprehenderit. Consequat est fugiat incididunt et voluptate ullamco mollit deserunt. Id Lorem esse cupidatat nulla sit dolor anim. Ad magna deserunt excepteur sunt nulla exercitation labore reprehenderit id consequat dolor aliqua dolor. Consequat officia dolore mollit cillum et.";
Cache.setMeasureCache({});
// console.log(
//   calcTextTypography2(txt, {
//     fontSize: 25,
//     fontFamily: "微软雅黑",
//     wrapWidth: 723,
//   }, true),
// );

console.log(
  createTextTypography(
    txt,
    { fontSize: 25, fontFamily: "微软雅黑", wrapWidth: 723 },
    true,
  ),
);
