// import convert from '@ohos/xml_js'
//
// const removeTextProperty = (node) => {
//   if (node && typeof node === 'object') {
//     Object.keys(node).forEach(key => {
//       if (node[key] && typeof node[key] === 'object') {
//         if ('_text' in node[key]) {
//           node[key] = node[key]._text;
//         } else {
//           removeTextProperty(node[key]);
//         }
//       }
//     });
//   }
//
//   return node;
// }
//
// const xmlToObj = (xml: string): object => {
//   const result = convert.xml2js(xml, {
//     compact: true,
//     ignoreDeclaration: true,
//     ignoreAttributes: true,
//     ignoreComment: true,
//     ignoreCdata: true
//   });
//
//   return removeTextProperty(result);
// }
//
// export {
//   xmlToObj
// };
